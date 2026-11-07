import Domain
import Foundation
import UIKit

/// What the Schedule's list shows: a Schedule, its rows and headers, and the Tasks and Days behind them.
struct ScheduleListContent {

    /// A section of the Schedule's list.
    nonisolated enum Section: Hashable, Sendable {
        case overdue
        case day(Date)
    }

    /// The Schedule the list shows, which the move rule answers for.
    let schedule: Schedule
    let today: Date
    /// The Tasks the list shows.
    let tasks: [TodoTask.ID: TodoTask]
    let overdueTaskIDs: Set<TodoTask.ID>
    /// The Days the list shows.
    let scheduleDays: [Date: Schedule.Day]
    /// The Tasks the list shows, in the order of its rows.
    private let taskIDs: [TodoTask.ID]

    init(schedule: Schedule, today: Date) {
        let shownTasks = schedule.overdue + schedule.days.flatMap(\.tasks)
        self.schedule = schedule
        self.today = today
        tasks = Dictionary(shownTasks.map { ($0.id, $0) }) { first, _ in first }
        overdueTaskIDs = Set(schedule.overdue.map(\.id))
        scheduleDays = Dictionary(schedule.days.map { ($0.day, $0) }) { first, _ in first }
        taskIDs = shownTasks.map(\.id)
    }

    // MARK: - Showing
    var snapshot: NSDiffableDataSourceSnapshot<Section, TodoTask.ID> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TodoTask.ID>()
        if !schedule.overdue.isEmpty {
            snapshot.appendSections([.overdue])
            snapshot.appendItems(schedule.overdue.map(\.id), toSection: .overdue)
        }
        for scheduleDay in schedule.days {
            snapshot.appendSections([.day(scheduleDay.day)])
            snapshot.appendItems(scheduleDay.tasks.map(\.id), toSection: .day(scheduleDay.day))
        }
        return snapshot
    }

    /// The rows to redraw when the list goes from showing `shown` to showing this, or `nil` when no Task or Today has
    /// changed. Rows added, removed or moved aren't redraws: the snapshot carries them.
    func redraw(from shown: ScheduleListContent) -> ScheduleListRedraw? {
        let changedTaskIDs = taskIDs.filter { id in shown.tasks[id].map { $0 != tasks[id] } ?? false }
        // A row names its Day only in Overdue, which a Task joins unchanged when Today rolls over.
        let overdueChangedTaskIDs = taskIDs.filter { id in
            shown.tasks[id] != nil && shown.overdueTaskIDs.contains(id) != overdueTaskIDs.contains(id)
        }
        guard !changedTaskIDs.isEmpty || !overdueChangedTaskIDs.isEmpty || today != shown.today else { return nil }
        return ScheduleListRedraw(
            reconfiguredTaskIDs: changedTaskIDs.filter { !overdueChangedTaskIDs.contains($0) },
            reloadedTaskIDs: overdueChangedTaskIDs
        )
    }
}

/// The rows the Schedule's list redraws as it shows new content.
struct ScheduleListRedraw: Equatable {
    /// Rows redrawn in place.
    let reconfiguredTaskIDs: [TodoTask.ID]
    /// Rows reloaded rather than reconfigured: a reconfigured row that also changes section lays out its new Day but
    /// isn't redrawn until it scrolls.
    let reloadedTaskIDs: [TodoTask.ID]
}
