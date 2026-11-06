import Data
import Domain
import FactoryKit
import Foundation

/// Moves Tasks in the Schedule at once and saves each Move, putting the Tasks back where the store holds them when a
/// save fails.
@MainActor
final class TaskMoves {
    private let scheduleTasks: ScheduleTasks
    private let writes: ScheduleWrites

    @Injected(\.todoTaskRepository) private var repository

    init(scheduleTasks: ScheduleTasks, writes: ScheduleWrites) {
        self.scheduleTasks = scheduleTasks
        self.writes = writes
    }

    // MARK: - Moving
    /// Moves `task` to `destination` and runs `onSaved` once the store has it, or lists it where it was when the
    /// move rule refuses that.
    func move(_ task: TodoTask, to destination: MoveDestination, onSaved: @escaping @MainActor () -> Void = {}) {
        // Moved at once, so the row stays where it was dropped while the write is in flight.
        guard scheduleTasks.move(task, to: destination) else { return }
        saveMove(task, to: destination, onSaved: onSaved)
    }

    /// Moves `task` to the end of `day` unless the move rule refuses it, and runs `onSaved` once the store has it, or
    /// `onFailure` once the Task is back where the store holds it. Returns whether it moved.
    @discardableResult
    func moveToEnd(
        _ task: TodoTask,
        of day: Date,
        onSaved: @escaping @MainActor () -> Void = {},
        onFailure: @escaping @MainActor () -> Void = {}
    ) -> Bool {
        guard let destination = scheduleTasks.moveToEnd(task, of: day) else { return false }
        saveMove(task, to: destination, onSaved: onSaved, onFailure: onFailure)
        return true
    }

    /// Moves the Overdue Tasks to the top of `day` in one save, unless the move rule refuses it, and runs `onSaved`
    /// once the store has them. Returns whether they moved: `false` when nothing is Overdue or the rule refuses `day`.
    func moveOverdueTasks(toStartOf day: Date, onSaved: @escaping @MainActor () -> Void) -> Bool {
        // Moved at once, so Overdue empties while the write is in flight.
        guard let ids = scheduleTasks.moveOverdueTasks(toStartOf: day) else { return false }
        writes.run {
            try await self.repository.move(ids: ids, toStartOf: day)
            onSaved()
        } onFailure: {
            // Nothing was saved, so the store's last Tasks put every Task back in Overdue.
            self.scheduleTasks.dropUnsavedMoves()
        }
        return true
    }

    // MARK: - Helpers
    /// Saves the Move of `task` to `destination`, already listed, and runs `onSaved` once the store has it, or
    /// `onFailure` once the Task is back where the store holds it.
    private func saveMove(
        _ task: TodoTask,
        to destination: MoveDestination,
        onSaved: @escaping @MainActor () -> Void,
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        writes.run {
            try await self.repository.move(id: task.id, to: destination)
            onSaved()
        } onFailure: {
            // Nothing was saved, so the store's last Tasks put the Task back.
            self.scheduleTasks.dropUnsavedMoves()
            onFailure()
        }
    }
}
