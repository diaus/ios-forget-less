import Foundation
import Utils

/// A Task: something the user plans to do on one Day. Named `TodoTask` so it doesn't shadow Swift's `Task`.
public struct TodoTask: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    /// The Task's Day, as 00:00 GMT.
    public var day: Date
    /// The Day the Task was made Complete; `nil` while Incomplete.
    public var completeDay: Date?
    /// The Task's place within its Day.
    public var sortIndex: Int

    public var isComplete: Bool { completeDay != nil }

    public init(id: UUID, name: String, day: Date, completeDay: Date?, sortIndex: Int) {
        self.id = id
        self.name = name
        self.day = day
        self.completeDay = completeDay
        self.sortIndex = sortIndex
    }

    // MARK: - Rules
    /// The end-of-Day rule: where a new Task goes in its Day.
    public static func nextSortIndex(in tasksOfDay: [TodoTask]) -> Int {
        (tasksOfDay.map(\.sortIndex).max() ?? -1) + 1
    }

    /// The name rule: the name `typed` is saved as, or `nil` when it can't be a Task's name.
    public static func savedName(from typed: String) -> String? {
        let name = typed.trimmed
        return name.isEmpty ? nil : name
    }

    /// The order rule: the Tasks of `destination`'s Day once `task` is moved there, in order and numbered from 0,
    /// `task` on that Day. A destination after a Task that isn't on the Day puts `task` at the end; a destination after
    /// `task` itself leaves it where it is.
    /// - Parameter tasksOfDay: Every Task of `destination`'s Day in order, hidden ones included, `task` or not.
    public static func order(
        afterMoving task: TodoTask,
        to destination: MoveDestination,
        in tasksOfDay: [TodoTask]
    ) -> [TodoTask] {
        var task = task
        task.day = destination.day
        var order = tasksOfDay.filter { $0.id != task.id }
        if let after = destination.after {
            // Filtering dropped `task` only if it was on the Day, where it then stays.
            if after == task.id, order.count < tasksOfDay.count {
                order = tasksOfDay
            } else {
                // A Task deleted meanwhile is no longer on the Day.
                let index = order.firstIndex { $0.id == after }.map { $0 + 1 } ?? order.endIndex
                order.insert(task, at: index)
            }
        } else {
            order.insert(task, at: 0)
        }
        return numbered(order)
    }

    /// The order rule for a Move to the top of `day`: the Tasks of `day` once `tasks` go first on it, in the order
    /// given, in order and numbered from 0, `tasks` on that Day.
    /// - Parameter tasksOfDay: Every Task of `day` in order, hidden ones included, any of `tasks` or not.
    public static func order(
        afterMoving tasks: [TodoTask],
        toStartOf day: Date,
        in tasksOfDay: [TodoTask]
    ) -> [TodoTask] {
        let movedIDs = Set(tasks.map(\.id))
        let moved = tasks.map { task in
            var task = task
            task.day = day
            return task
        }
        return numbered(moved + tasksOfDay.filter { !movedIDs.contains($0.id) })
    }

    // MARK: - Helpers
    private static func numbered(_ order: [TodoTask]) -> [TodoTask] {
        order.enumerated().map { sortIndex, task in
            var task = task
            task.sortIndex = sortIndex
            return task
        }
    }
}
