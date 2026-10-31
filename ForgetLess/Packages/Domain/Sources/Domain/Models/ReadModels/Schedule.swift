import Foundation

/// What the Schedule screen lists.
public struct Schedule: Sendable {
    /// A Day of the Schedule and its Tasks.
    public struct Day: Identifiable, Sendable {
        public let day: Date
        public let tasks: [TodoTask]

        public var id: Date { day }
    }

    /// The Overdue Tasks, with those completed from it on Today, oldest Day first.
    public let overdue: [TodoTask]
    public let days: [Day]

    /// How many Days the window holds, Today included.
    private static let windowDayCount = 100

    /// - Parameters:
    ///   - tasks: In order of Day, then position within it, as the repository sends them.
    ///   - showsComplete: Whether Complete Tasks are listed.
    ///   - keptTaskIDs: Complete Tasks listed even while Complete Tasks are hidden, so a mis-tap can be undone.
    public init(tasks: [TodoTask], today: Date, showsComplete: Bool = true, keptTaskIDs: Set<UUID> = []) {
        let tasks = showsComplete ? tasks : tasks.filter { !$0.isComplete || keptTaskIDs.contains($0.id) }
        // A Task completed from Overdue stays there until Today rolls over, so a mis-tap can be undone.
        overdue = tasks.filter { $0.day < today && ($0.completeDay ?? .distantFuture) >= today }
        // Grouping keeps each Day's Tasks in the order given.
        let tasksByDay = Dictionary(grouping: tasks) { $0.day }
        let window = (0..<Self.windowDayCount).map { today.addingDays($0) }
        let afterWindow = today.addingDays(Self.windowDayCount)
        var laterDays: [Date] = []
        // The input is in Day order, so each Day's Tasks are next to each other and its first one adds it.
        for task in tasks where task.day >= afterWindow && laterDays.last != task.day {
            laterDays.append(task.day)
        }
        days = (window + laterDays).map { day in Day(day: day, tasks: tasksByDay[day, default: []]) }
    }
}
