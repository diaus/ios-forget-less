import Domain
import FactoryKit
import SwiftUI
import UIKit

/// Feeds a `Schedule` to the Schedule's collection view, and runs the actions of its rows and headers.
final class ScheduleListController: NSObject, UICollectionViewDelegate {

    /// A section of the Schedule's list.
    nonisolated enum Section: Hashable, Sendable {
        case overdue
        case day(Date)
    }

    /// A Day's header, a type of its own so it's never reused for the Overdue header.
    final class DayHeaderCell: UICollectionViewListCell {}

    let collectionView = ScheduleCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    /// The list as SwiftUI last described it, for the composer its rows and headers show.
    var listView: ScheduleListView
    @Injected(\.scheduleViewModel) private var vm
    private var dataSource: UICollectionViewDiffableDataSource<Section, TodoTask.ID>?
    /// The Tasks the list shows.
    private var tasks: [TodoTask.ID: TodoTask] = [:]
    private var overdueTaskIDs: Set<TodoTask.ID> = []
    /// The Days the list shows.
    private var scheduleDays: [Date: Schedule.Day] = [:]
    private var today = Date.today
    /// The Schedule the list shows, which the move rule answers for.
    private var schedule = Schedule(tasks: [], today: .today)
    private var movesTasks = false
    private let rowMove = TaskRowMove()
    /// The reveal last carried out, so each is carried out once.
    private var lastReveal: DayReveal?
    /// The Task whose row is drawn highlighted, while its floating Day calendar is open.
    private var highlightedTaskID: TodoTask.ID?

    init(listView: ScheduleListView) {
        self.listView = listView
        super.init()
        // Set here rather than at creation, so its swipe actions can call back into `self`.
        collectionView.collectionViewLayout = makeLayout()
        collectionView.delegate = self
        configureDataSource()
    }

    // MARK: - Showing
    /// Shows `schedule`, animating the change when `animated` and it isn't the first.
    func show(_ schedule: Schedule, today: Date, movesTasks: Bool, animated: Bool) {
        guard let dataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, TodoTask.ID>()
        if !schedule.overdue.isEmpty {
            snapshot.appendSections([.overdue])
            snapshot.appendItems(schedule.overdue.map(\.id), toSection: .overdue)
        }
        for scheduleDay in schedule.days {
            snapshot.appendSections([.day(scheduleDay.day)])
            snapshot.appendItems(scheduleDay.tasks.map(\.id), toSection: .day(scheduleDay.day))
        }
        let shownSnapshot = dataSource.snapshot()
        let isFirst = shownSnapshot.numberOfSections == 0
        let shownTasks = schedule.overdue + schedule.days.flatMap(\.tasks)
        let newOverdueTaskIDs = Set(schedule.overdue.map(\.id))
        let changedTaskIDs = shownTasks.filter { task in tasks[task.id].map { $0 != task } ?? false }.map(\.id)
        // A row names its Day only in Overdue, which a Task joins unchanged when Today rolls over.
        let overdueChangedTaskIDs = shownTasks.map(\.id).filter { id in
            tasks[id] != nil && overdueTaskIDs.contains(id) != newOverdueTaskIDs.contains(id)
        }
        // SwiftUI updates the list whenever the screen changes, the composer included, mostly with nothing new.
        let movesTasksChanged = movesTasks != self.movesTasks
        if !isFirst, changedTaskIDs.isEmpty, overdueChangedTaskIDs.isEmpty, today == self.today, !movesTasksChanged,
           Self.sameRows(snapshot, shownSnapshot) {
            return
        }
        if rowMove.taskID != nil {
            // Rows can't change under a lifted one, and a new Today changes where it can land: the move is cancelled.
            collectionView.cancelInteractiveMovement()
            rowMove.end()
        }
        tasks = Dictionary(shownTasks.map { ($0.id, $0) }) { first, _ in first }
        overdueTaskIDs = newOverdueTaskIDs
        scheduleDays = Dictionary(schedule.days.map { ($0.day, $0) }) { first, _ in first }
        self.today = today
        self.schedule = schedule
        self.movesTasks = movesTasks
        // Rows are keyed by Task ID, so a renamed or completed Task is redrawn in place, and every row shows or hides
        // its handle.
        let reconfiguredTaskIDs = movesTasksChanged ? snapshot.itemIdentifiers : changedTaskIDs
        snapshot.reconfigureItems(reconfiguredTaskIDs.filter { !overdueChangedTaskIDs.contains($0) })
        // Reloaded rather than reconfigured: a reconfigured row that also changes section lays out its new Day but
        // isn't redrawn until it scrolls.
        snapshot.reloadItems(overdueChangedTaskIDs)
        dataSource.apply(snapshot, animatingDifferences: animated && !isFirst)
        // Headers aren't reconfigured by the snapshot, and an emptied Day or a new Today changes how one reads.
        reconfigureVisibleHeaders()
    }

    /// Brings the last Task of `reveal`'s Day into view, unless `reveal` was carried out before.
    func reveal(_ reveal: DayReveal?) {
        guard let reveal, reveal != lastReveal else { return }
        lastReveal = reveal
        guard let dataSource else { return }
        let section = Section.day(reveal.day)
        let snapshot = dataSource.snapshot()
        // Asking a snapshot for a section it lacks raises an exception.
        guard snapshot.indexOfSection(section) != nil,
              let lastTaskID = snapshot.itemIdentifiers(inSection: section).last,
              let indexPath = dataSource.indexPath(for: lastTaskID) else { return }
        collectionView.scrollToShowRow(at: indexPath)
    }

    /// Highlights the row of the Task with `id`, and only that row; `nil` highlights none.
    func highlightRow(of id: TodoTask.ID?) {
        guard id != highlightedTaskID else { return }
        let changedIDs = [highlightedTaskID, id].compactMap { $0 }
        highlightedTaskID = id
        for changedID in changedIDs {
            dataSource?.indexPath(for: changedID).flatMap(collectionView.cellForItem)?.setNeedsUpdateConfiguration()
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
        let overdueHeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { header, _, _ in
            header.contentConfiguration = UIHostingConfiguration { OverdueHeaderView() }
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
        guard let task = tasks[id] else { return }
        cell.contentConfiguration = UIHostingConfiguration {
            TaskRowView(task: task, showsDay: overdueTaskIDs.contains(id)) { [weak self] in
                self?.edit(id)
            } onChooseDay: { [weak self] in
                self?.chooseDay(id)
            }
        }
        // The row draws its margins above and below as padding, so they take its taps.
        .margins(.vertical, 0)
        cell.accessories = movesTasks ? [.reorder(displayed: .always)] : []
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
              let scheduleDay = scheduleDays[day] else { return }
        let onAdd = { [weak self] in self?.listView.onAdd(day) ?? () }
        header.contentConfiguration = UIHostingConfiguration {
            DayHeaderView(scheduleDay: scheduleDay, onAdd: onAdd)
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

    /// Only Day headers: the Overdue header never changes.
    private func reconfigureVisibleHeaders() {
        let kind = UICollectionView.elementKindSectionHeader
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            if let header = collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? DayHeaderCell {
                configure(header, section: indexPath.section)
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
              let task = tasks[id],
              case let .day(day)? = finalSnapshot.sectionIdentifier(containingItem: id),
              let index = finalSnapshot.itemIdentifiers(inSection: .day(day)).firstIndex(of: id) else { return }
        vm.move(task, to: schedule.destination(forDropOf: task, on: day, at: index))
    }

    /// The move rule's answer for the row with `id` dropped at `indexPath`.
    private func canMove(_ id: TodoTask.ID, to indexPath: IndexPath) -> Bool {
        // Overdue has no Day to give a Task.
        guard let task = tasks[id], case let .day(day)? = dataSource?.sectionIdentifier(for: indexPath.section) else {
            return false
        }
        return schedule.canMove(task, droppedOn: day, at: indexPath.item)
    }

    private func canStartOrContinueMove(_ id: TodoTask.ID) -> Bool {
        guard movesTasks else { return false }
        let row = dataSource?.indexPath(for: id).flatMap { collectionView.cellForItem(at: $0) } as? TaskRowCell
        return rowMove.taskID == id || row?.isHandleTouched == true
    }

    // MARK: - Helpers
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

// In an extension, so the class's body stays within SwiftLint's length.
extension ScheduleListController {
    // MARK: - Row Actions
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        // Rows take taps in SwiftUI, never as a selection: a row tap edits the Task or opens its calendar.
        false
    }

    private func edit(_ id: TodoTask.ID) {
        if let task = tasks[id] {
            listView.onEdit(task)
        }
    }

    private func chooseDay(_ id: TodoTask.ID) {
        guard let task = tasks[id], let indexPath = dataSource?.indexPath(for: id),
              let cell = collectionView.cellForItem(at: indexPath) as? TaskRowCell else { return }
        let row = cell.convert(cell.bounds, to: nil)
        let tap = cell.lastTouchLocation ?? CGPoint(x: row.midX, y: row.midY)
        listView.onChooseDay(task, TaskDayCalendarOrigin(row: row, tap: tap))
    }

    private func swipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = dataSource?.itemIdentifier(for: indexPath) else { return nil }
        return .taskRowActions { [weak self] in
            self?.confirmDeletion(of: id)
        } onChooseDay: { [weak self] in
            if let task = self?.tasks[id] {
                self?.vm.showDayPicker(for: task)
            }
        }
    }

    private func confirmDeletion(of id: TodoTask.ID) {
        guard let task = tasks[id],
              let indexPath = dataSource?.indexPath(for: id),
              let cell = collectionView.cellForItem(at: indexPath),
              var presenter = collectionView.window?.rootViewController else { return }
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let alert = UIAlertController(
            title: String(localized: .taskDeleteConfirmation(name: task.name)),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: String(localized: .taskDelete), style: .destructive) { [weak self] _ in
            self?.vm.delete(task)
        })
        alert.addAction(UIAlertAction(title: String(localized: .taskDeleteCancel), style: .cancel))
        // Pointing at the row, as the dialog did when SwiftUI drew it.
        alert.popoverPresentationController?.sourceView = cell
        alert.popoverPresentationController?.sourceRect = cell.bounds
        presenter.present(alert, animated: true)
    }
}
