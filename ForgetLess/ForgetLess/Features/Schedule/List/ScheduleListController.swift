import Domain
import SwiftUI
import UIKit

/// Feeds a `Schedule` to the Schedule's collection view, and runs the actions of its rows and headers.
final class ScheduleListController: NSObject, UICollectionViewDelegate {

    /// A section of the Schedule's list.
    nonisolated enum Section: Hashable, Sendable {
        case overdue
        case day(Date)
    }

    let collectionView = ScheduleCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    /// The list as SwiftUI last described it, for the actions the rows and headers call.
    var listView: ScheduleListView
    private var dataSource: UICollectionViewDiffableDataSource<Section, TodoTask.ID>?
    /// The Tasks the list shows.
    private var tasks: [TodoTask.ID: TodoTask] = [:]
    private var overdueTaskIDs: Set<TodoTask.ID> = []
    /// The Days the list shows.
    private var scheduleDays: [Date: Schedule.Day] = [:]
    private var today = Date.today

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
    func show(_ schedule: Schedule, today: Date, animated: Bool) {
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
        if !isFirst, changedTaskIDs.isEmpty, overdueChangedTaskIDs.isEmpty, today == self.today,
           Self.sameRows(snapshot, shownSnapshot) {
            return
        }
        tasks = Dictionary(shownTasks.map { ($0.id, $0) }) { first, _ in first }
        overdueTaskIDs = newOverdueTaskIDs
        scheduleDays = Dictionary(schedule.days.map { ($0.day, $0) }) { first, _ in first }
        self.today = today
        // Rows are keyed by Task ID, so a renamed or completed Task is redrawn in place.
        snapshot.reconfigureItems(changedTaskIDs.filter { !overdueChangedTaskIDs.contains($0) })
        // Reloaded rather than reconfigured: a reconfigured row that also changes section lays out its new Day but
        // isn't redrawn until it scrolls.
        snapshot.reloadItems(overdueChangedTaskIDs)
        dataSource.apply(snapshot, animatingDifferences: animated && !isFirst)
        // Headers aren't reconfigured by the snapshot, and an emptied Day or a new Today changes how one reads.
        reconfigureVisibleHeaders()
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
        typealias RowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TodoTask.ID>
        let rowRegistration = RowRegistration { [weak self] cell, _, id in
            self?.configure(cell, id: id)
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            self?.configure(header, section: indexPath.section)
        }
        let dataSource = UICollectionViewDiffableDataSource<Section, TodoTask.ID>(
            collectionView: collectionView
        ) { collectionView, indexPath, id in
            collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: id)
        }
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        self.dataSource = dataSource
    }

    private func configure(_ cell: UICollectionViewListCell, id: TodoTask.ID) {
        guard let task = tasks[id] else { return }
        let composerOpenerFocus = listView.composerOpenerFocus
        cell.contentConfiguration = UIHostingConfiguration {
            TaskRowView(
                task: task,
                showsDay: overdueTaskIDs.contains(id),
                composerOpenerFocus: composerOpenerFocus
            ) { [weak self] in
                self?.rename(id)
            }
        }
    }

    private func configure(_ header: UICollectionViewListCell, section: Int) {
        switch dataSource?.sectionIdentifier(for: section) {
        case .overdue:
            header.contentConfiguration = UIHostingConfiguration { OverdueHeaderView() }
        case let .day(day):
            guard let scheduleDay = scheduleDays[day] else { return }
            let today = today
            let composerOpenerFocus = listView.composerOpenerFocus
            let onAdd = { [weak self] in self?.listView.onAdd(day) ?? () }
            header.contentConfiguration = UIHostingConfiguration {
                DayHeaderView(
                    scheduleDay: scheduleDay,
                    today: today,
                    composerOpenerFocus: composerOpenerFocus,
                    onAdd: onAdd
                )
            }
        case nil:
            break
        }
    }

    private func reconfigureVisibleHeaders() {
        let kind = UICollectionView.elementKindSectionHeader
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            if let header = collectionView.supplementaryView(forElementKind: kind, at: indexPath)
                as? UICollectionViewListCell {
                configure(header, section: indexPath.section)
            }
        }
    }

    // MARK: - Row Actions
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        // Rows take taps in SwiftUI, never as a selection: a row tap is for renaming.
        false
    }

    private func rename(_ id: TodoTask.ID) {
        if let task = tasks[id] {
            listView.onRename(task)
        }
    }

    private func swipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = dataSource?.itemIdentifier(for: indexPath) else { return nil }
        // No title, so only the icon shows; VoiceOver reads the icon's label.
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            self?.confirmDeletion(of: id)
            completion(true)
        }
        let image = UIImage(systemName: "trash")
        image?.accessibilityLabel = String(localized: .taskDelete)
        delete.image = image
        delete.backgroundColor = UIColor(resource: .deleteAction)
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        // No full swipe: deleting always asks first.
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
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
            self?.listView.onDelete(task)
        })
        alert.addAction(UIAlertAction(title: String(localized: .taskDeleteCancel), style: .cancel))
        // Pointing at the row, as the dialog did when SwiftUI drew it.
        alert.popoverPresentationController?.sourceView = cell
        alert.popoverPresentationController?.sourceRect = cell.bounds
        presenter.present(alert, animated: true)
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
