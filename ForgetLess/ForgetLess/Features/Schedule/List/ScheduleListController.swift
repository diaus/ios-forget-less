import Domain
import FactoryKit
import SwiftUI
import UIKit

/// Feeds a `Schedule` to the Schedule's collection view, and runs the actions of its rows and headers.
final class ScheduleListController: NSObject, UICollectionViewDelegate {

    private typealias Section = ScheduleListContent.Section

    /// A Day's header, a type of its own so it's never reused for the Overdue header.
    final class DayHeaderCell: UICollectionViewListCell {}

    let collectionView = ScheduleCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    @Injected(\.scheduleViewModel) private var vm
    private var dataSource: UICollectionViewDiffableDataSource<Section, TodoTask.ID>?
    /// What the list last showed.
    private var content = ScheduleListContent(schedule: Schedule(tasks: [], today: .today), today: .today)
    private let rowMove = TaskRowMove()
    private lazy var scroller = ScheduleListScroller(collectionView: collectionView)
    /// The Task whose row is drawn highlighted, while its floating Day picker is open.
    private var highlightedTaskID: TodoTask.ID?

    override init() {
        super.init()
        // Set here rather than at creation, so its swipe actions can call back into `self`.
        collectionView.collectionViewLayout = makeLayout()
        collectionView.delegate = self
        configureDataSource()
    }

    // MARK: - Showing
    /// Shows `schedule`, animating the change when `animated` and it isn't the first.
    func show(_ schedule: Schedule, today: Date, animated: Bool) {
        guard let dataSource else { return }
        let content = ScheduleListContent(schedule: schedule, today: today)
        var snapshot = content.snapshot
        let shownSnapshot = dataSource.snapshot()
        let isFirst = shownSnapshot.numberOfSections == 0
        let redraw = content.redraw(from: self.content)
        let shownHistoryFirstDay = self.content.schedule.historyFirstDay
        // SwiftUI updates the list whenever the screen changes, the composer included, mostly with nothing new.
        // Compared with the rows on screen, not the last content: a refused drop leaves its row moved there.
        if !isFirst, redraw == nil, Self.sameRows(snapshot, shownSnapshot) {
            return
        }
        if rowMove.taskID != nil {
            // Rows can't change under a lifted one, and a new Today changes where it can land: the move is cancelled.
            collectionView.cancelInteractiveMovement()
            rowMove.end()
        }
        self.content = content
        // Rows are keyed by Task ID, so a renamed or completed Task is redrawn in place.
        snapshot.reconfigureItems(redraw?.reconfiguredTaskIDs ?? [])
        snapshot.reloadItems(redraw?.reloadedTaskIDs ?? [])
        // Days added or removed above the screen by a page of History landing, or History turning on or off, would
        // otherwise push the rows on screen along. A jump may follow, which then starts from where the user was.
        let holdsStill = !isFirst && !animated && schedule.historyFirstDay != shownHistoryFirstDay
        scroller.apply(snapshot, over: shownSnapshot, holdingStill: holdsStill) {
            dataSource.apply(snapshot, animatingDifferences: animated && !isFirst)
        }
        // An emptied Day or a new Today changes how a Day's header reads, and the Overdue header shows Move All only
        // while Overdue holds an Incomplete Task.
        reconfigureVisibleHeaders()
    }

    /// Brings the last Task of `reveal`'s Day into view, unless `reveal` was carried out before.
    func reveal(_ reveal: DayReveal?) {
        if let dataSource { scroller.reveal(reveal, in: dataSource.snapshot()) }
    }

    /// Scrolls where `jump` asks, unless `jump` was carried out before.
    func jump(_ jump: HistoryJump?) {
        if let dataSource { scroller.jump(jump, today: content.today, in: dataSource.snapshot()) }
    }

    /// Highlights the row of the Task with `id`, and only that row; `nil` highlights none.
    func highlightRow(of id: TodoTask.ID?) {
        guard id != highlightedTaskID else { return }
        let changedIDs = [highlightedTaskID, id].compactMap { $0 }
        highlightedTaskID = id
        for changedID in changedIDs {
            visibleCell(for: changedID)?.setNeedsUpdateConfiguration()
        }
    }

    // MARK: - Configuration
    private func makeLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.swipeActions(at: indexPath)
        }
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    private func configureDataSource() {
        typealias RowRegistration = UICollectionView.CellRegistration<TaskRowCell, TodoTask.ID>
        let rowRegistration = RowRegistration { [weak self] cell, _, id in
            self?.configure(cell, id: id)
        }
        // One registration per header kind, so a reused header never swaps one SwiftUI view type for another.
        let overdueHeaderRegistration = UICollectionView.SupplementaryRegistration<OverdueHeaderCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, _ in
            self?.configure(header)
        }
        let dayHeaderRegistration = UICollectionView.SupplementaryRegistration<DayHeaderCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            self?.configure(header, section: indexPath.section)
        }
        let dataSource = UICollectionViewDiffableDataSource<Section, TodoTask.ID>(
            collectionView: collectionView
        ) { collectionView, indexPath, id in
            collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: id)
        }
        dataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            switch self?.dataSource?.sectionIdentifier(for: indexPath.section) {
            case .overdue:
                collectionView.dequeueConfiguredReusableSupplementary(using: overdueHeaderRegistration, for: indexPath)
            case .day, nil:
                collectionView.dequeueConfiguredReusableSupplementary(using: dayHeaderRegistration, for: indexPath)
            }
        }
        // Off, no row moves, not even from a long press. On, a row moves only from its handle: UIKit also asks
        // when VoiceOver reads a row, and would add its own move actions, which ignore the move rule.
        dataSource.reorderingHandlers.canReorderItem = { [weak self] id in
            self?.canStartOrContinueMove(id) ?? false
        }
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            self?.didMove(transaction)
        }
        self.dataSource = dataSource
    }

    private func configure(_ cell: UICollectionViewListCell, id: TodoTask.ID) {
        guard let task = content.tasks[id] else { return }
        cell.contentConfiguration = UIHostingConfiguration {
            TaskRowView(task: task, showsDay: content.overdueTaskIDs.contains(id)) { [weak self] in
                self?.chooseDay(id)
            }
        }
        // The row draws its margins above and below as padding, so they take its taps.
        .margins(.vertical, 0)
        cell.accessories = [.reorder(displayed: .always)]
        cell.configurationUpdateHandler = { [weak self] cell, state in
            self?.rowStateChanged(state, id: id)
            var background = cell.defaultBackgroundConfiguration().updated(for: state)
            if self?.highlightedTaskID == id {
                background.backgroundColor = UIColor(resource: .taskRowHighlight)
            }
            cell.backgroundConfiguration = background
        }
    }

    private func configure(_ header: DayHeaderCell, section: Int) {
        guard case let .day(day) = dataSource?.sectionIdentifier(for: section),
              let scheduleDay = content.scheduleDays[day] else { return }
        header.contentConfiguration = UIHostingConfiguration {
            DayHeaderView(scheduleDay: scheduleDay)
        }
        // Weeks delimiter line
        .background {
            if scheduleDay.startsWeek {
                Color(uiColor: .separator)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private func configure(_ header: OverdueHeaderCell) {
        let showsMoveAll = !content.schedule.overdueIncomplete.isEmpty
        header.contentConfiguration = UIHostingConfiguration {
            OverdueHeaderView(showsMoveAll: showsMoveAll) { [weak self] in
                self?.chooseOverdueDay()
            }
        }
    }

    /// Redraws the headers on screen for the content shown, which the snapshot doesn't reconfigure.
    private func reconfigureVisibleHeaders() {
        let kind = UICollectionView.elementKindSectionHeader
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            switch collectionView.supplementaryView(forElementKind: kind, at: indexPath) {
            case let header as DayHeaderCell:
                configure(header, section: indexPath.section)
            case let header as OverdueHeaderCell:
                configure(header)
            default:
                break
            }
        }
    }

    // MARK: - Moving
    func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
        atCurrentIndexPath currentIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        guard let id = dataSource?.itemIdentifier(for: originalIndexPath) else { return originalIndexPath }
        // The list's own proposal can't be trusted across Days: it never proposes an empty Day, it proposes the next
        // Day while the row is still over the top half of its header, and in a Day entered from another it proposes
        // only the edge the row came in at. So the drop follows where the row is.
        let liftedRow = collectionView.visibleCells.first { cell in
            (cell as? UICollectionViewListCell)?.configurationState.isReordering == true
        }
        let proposed = liftedRow.flatMap { row in
            self.collectionView.moveTarget(at: row.center, from: currentIndexPath)
        } ?? proposedIndexPath
        let isAccepted = canMove(id, to: proposed)
        rowMove.tickOnEntering(isAccepted ? proposed.section : nil, startedIn: originalIndexPath.section)
        // Refused, no gap opens, and letting go puts the row back where it started.
        return isAccepted ? proposed : originalIndexPath
    }

    private func rowStateChanged(_ state: UICellConfigurationState, id: TodoTask.ID) {
        if state.isReordering {
            rowMove.lift(id)
        } else if rowMove.taskID == id {
            rowMove.end()
        }
    }

    private func didMove(_ transaction: NSDiffableDataSourceTransaction<Section, TodoTask.ID>) {
        rowMove.end()
        let finalSnapshot = transaction.finalSnapshot
        guard case let .insert(_, id, _)? = transaction.difference.insertions.first,
              let task = content.tasks[id],
              case let .day(day)? = finalSnapshot.sectionIdentifier(containingItem: id),
              let index = finalSnapshot.itemIdentifiers(inSection: .day(day)).firstIndex(of: id) else { return }
        vm.move(task, to: content.schedule.destination(forDropOf: task, on: day, at: index))
    }

    /// The move rule's answer for the row with `id` dropped at `indexPath`.
    private func canMove(_ id: TodoTask.ID, to indexPath: IndexPath) -> Bool {
        // Overdue has no Day to give a Task.
        guard let task = content.tasks[id],
              case let .day(day)? = dataSource?.sectionIdentifier(for: indexPath.section) else { return false }
        return content.schedule.canMove(task, droppedOn: day, at: indexPath.item)
    }

    private func canStartOrContinueMove(_ id: TodoTask.ID) -> Bool {
        let row = visibleCell(for: id) as? TaskRowCell
        return rowMove.taskID == id || row?.isHandleTouched == true
    }

    // MARK: - Row and Header Actions
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        // Rows take taps in SwiftUI, never as a selection: a row tap edits the Task or opens its floating Day picker.
        false
    }

    /// Opens the Task's floating Day picker from its row, which only the list can place on screen.
    private func chooseDay(_ id: TodoTask.ID) {
        guard let task = content.tasks[id], let cell = visibleCell(for: id) as? TaskRowCell else { return }
        let row = cell.convert(cell.bounds, to: nil)
        let tap = cell.lastTouchLocation ?? CGPoint(x: row.midX, y: row.midY)
        vm.showFloatingDayPicker(for: task, from: FloatingDayPickerOrigin(frame: row, tap: tap))
    }

    /// Opens the floating Day picker for the Overdue Tasks from their header, which only the list can place on screen.
    private func chooseOverdueDay() {
        let kind = UICollectionView.elementKindSectionHeader
        guard let section = dataSource?.snapshot().indexOfSection(.overdue),
              let frame = collectionView.headerFrameWithinRowMargins(ofSection: section) else { return }
        let header = collectionView.supplementaryView(forElementKind: kind, at: IndexPath(item: 0, section: section))
        let tap = (header as? OverdueHeaderCell)?.lastTouchLocation ?? CGPoint(x: frame.midX, y: frame.midY)
        vm.showOverdueFloatingDayPicker(from: FloatingDayPickerOrigin(frame: frame, tap: tap))
    }

    private func swipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = dataSource?.itemIdentifier(for: indexPath) else { return nil }
        return .taskRowActions { [weak self] in
            self?.confirmDeletion(of: id)
        } onChooseDay: { [weak self] in
            if let task = self?.content.tasks[id] {
                self?.vm.showSheetDayPicker(on: task.day, for: .task(task.id))
            }
        }
    }

    private func confirmDeletion(of id: TodoTask.ID) {
        guard let task = content.tasks[id],
              let cell = visibleCell(for: id),
              var presenter = collectionView.window?.rootViewController else { return }
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let alert = UIAlertController.taskDeletionConfirmation(of: task, from: cell) { [weak self] in
            self?.vm.delete(task)
        }
        presenter.present(alert, animated: true)
    }

    // MARK: - Helpers
    /// The row of the Task with `id`, or `nil` while it's off screen.
    private func visibleCell(for id: TodoTask.ID) -> UICollectionViewCell? {
        dataSource?.indexPath(for: id).flatMap(collectionView.cellForItem)
    }

    /// Whether two snapshots hold the same sections, each with the same rows in the same order.
    private static func sameRows(
        _ snapshot: NSDiffableDataSourceSnapshot<Section, TodoTask.ID>,
        _ other: NSDiffableDataSourceSnapshot<Section, TodoTask.ID>
    ) -> Bool {
        snapshot.sectionIdentifiers == other.sectionIdentifiers
            && snapshot.sectionIdentifiers.allSatisfy { section in
                snapshot.itemIdentifiers(inSection: section) == other.itemIdentifiers(inSection: section)
            }
    }
}

// MARK: - Scrolling
// An extension, so the type's body stays within SwiftLint's length.
extension ScheduleListController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.isNearTop { vm.loadEarlierHistory() }
    }
}
