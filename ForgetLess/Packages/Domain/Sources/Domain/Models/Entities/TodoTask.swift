import Foundation

/// A Task: something the user plans to do on one Day. Named `TodoTask` so it doesn't shadow Swift's `Task`.
public struct TodoTask: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    /// The Task's Day, as 00:00 GMT.
    public var day: Date
    public var isComplete: Bool
    /// The Task's place within its Day.
    public var sortIndex: Int

    public init(id: UUID, name: String, day: Date, isComplete: Bool, sortIndex: Int) {
        self.id = id
        self.name = name
        self.day = day
        self.isComplete = isComplete
        self.sortIndex = sortIndex
    }

    /// The end-of-Day rule: where a new Task goes in its Day.
    public static func nextSortIndex(in tasksOfDay: [TodoTask]) -> Int {
        (tasksOfDay.map(\.sortIndex).max() ?? -1) + 1
    }
}
