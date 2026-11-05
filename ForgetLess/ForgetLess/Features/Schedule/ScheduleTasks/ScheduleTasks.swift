import Domain
import Foundation
import Observation

/// The Tasks the Schedule lists, with any Move not yet saved already made, and the Schedule listing them.
@MainActor @Observable
final class ScheduleTasks {
    private(set) var schedule: Schedule
    /// How many Incomplete Tasks each Day holds; a Day with none has no entry.
    private(set) var incompleteTaskCountsByDay: [Date: Int] = [:]
    /// What the Tasks are listed by, read afresh each time they're listed. The owner sets it right after creating
    /// these Tasks, before it lists any.
    @ObservationIgnored var listing: (@MainActor () -> ScheduleListing)!
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

    /// Lists `tasks`, just observed in the store, in place of any Move not yet saved.
    func observe(_ tasks: [TodoTask]) {
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
            keptTaskIDs: listing.keptTaskIDs
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

    /// Lists the Tasks as the store last held them, once a Move failed to save.
    func dropUnsavedMoves() {
        listed = stored
        relist()
    }
}
