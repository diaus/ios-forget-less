import Domain
import Foundation
import Observation

/// The Tasks the Schedule lists, with any Move not yet saved already made, and the Schedule listing them.
@MainActor @Observable
final class ScheduleTasks {
    private(set) var schedule: Schedule
    /// How many Incomplete Tasks each Day holds; a Day with none has no entry.
    private(set) var incompleteTaskCountsByDay: [Date: Int] = [:]
    /// The first Day the Tasks were last observed from, in History, or `nil` when they were observed outside it: the
    /// first Day the Schedule lists in History, so it never lists a Day before Today whose Tasks haven't arrived.
    private(set) var historyFirstDay: Date?
    /// What the Tasks are listed by, read afresh each time they're listed. The owner sets it right after creating
    /// these Tasks, before it lists any.
    @ObservationIgnored var listing: @MainActor () -> ScheduleListing = {
        preconditionFailure("ScheduleTasks listed before its owner set the listing")
    }
    /// The Tasks listed: those stored, with any Move not yet saved already made.
    private var listed: [TodoTask] = []
    /// The Tasks last observed in the store.
    private var stored: [TodoTask] = []

    /// Lists no Task yet, on `today`.
    init(today: Date) {
        schedule = Schedule(tasks: [], today: today)
    }

    // MARK: - Listing
    /// The listed Task with `id`, or `nil` when none has it.
    func task(withID id: UUID) -> TodoTask? {
        listed.first { $0.id == id }
    }

    /// Lists `tasks`, just observed in the store from `historyFirstDay` on in History, or outside History when
    /// `nil`, in place of any Move not yet saved.
    func observe(_ tasks: [TodoTask], historyFirstDay: Date?) {
        self.historyFirstDay = historyFirstDay
        stored = tasks
        listed = tasks
        relist()
    }

    func incompleteTaskCount(on day: Date) -> Int {
        incompleteTaskCountsByDay[day] ?? 0
    }

    func relist() {
        let listing = listing()
        schedule = Schedule(
            tasks: listed,
            today: listing.today,
            showsComplete: listing.showsComplete,
            keptTaskIDs: listing.keptTaskIDs,
            historyFirstDay: historyFirstDay
        )
        incompleteTaskCountsByDay = listed.incompleteTaskCountsByDay
    }

    // MARK: - Moving
    /// Moves `task` to `destination` ahead of the store, unless the move rule refuses it. Returns whether it moved. A
    /// refused Move relists all the same, so a list that already moved the row puts it back.
    func move(_ task: TodoTask, to destination: MoveDestination) -> Bool {
        guard schedule.canMove(task, to: destination) else {
            relist()
            return false
        }
        listed = listed.movingTask(id: task.id, to: destination)
        relist()
        return true
    }

    /// Moves `task` to the end of `day` ahead of the store, unless the move rule refuses it. Returns where it moved
    /// to, or `nil` when refused.
    func moveToEnd(_ task: TodoTask, of day: Date) -> MoveDestination? {
        guard schedule.canMoveToEnd(task, of: day) else { return nil }
        let destination = listed.destinationAtEnd(of: day, forTaskWithID: task.id)
        listed = listed.movingTask(id: task.id, to: destination)
        relist()
        return destination
    }

    /// Moves the Overdue Tasks, in Overdue's order, to the top of `day` ahead of the store, unless the move rule
    /// refuses it. Returns the IDs of the Tasks moved, in that order, or `nil` when refused.
    func moveOverdueTasks(toStartOf day: Date) -> [UUID]? {
        guard schedule.canMoveOverdueTasks(toStartOf: day) else { return nil }
        let ids = schedule.overdueIncomplete.map(\.id)
        listed = listed.movingTasks(ids: ids, toStartOf: day)
        relist()
        return ids
    }

    /// Lists the Tasks as the store last held them, once a Move failed to save.
    func dropUnsavedMoves() {
        listed = stored
        relist()
    }
}
