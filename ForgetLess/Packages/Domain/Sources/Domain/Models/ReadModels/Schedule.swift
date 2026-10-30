import Foundation

/// What the Schedule screen lists.
public struct Schedule: Sendable {
    /// A Day of the Schedule and its Tasks.
    public struct Day: Identifiable, Sendable {
        public let day: Date
        public let tasks: [TodoTask]

        public var id: Date { day }
    }

    public let days: [Day]

    /// How many Days the window holds, Today included.
    private static let windowDayCount = 100

    public init(tasks: [TodoTask], today: Date) {
        let tasksByDay = Dictionary(grouping: tasks) { $0.day }
        let window = (0..<Self.windowDayCount).map { today.addingDays($0) }
        let afterWindow = today.addingDays(Self.windowDayCount)
        let laterDays = tasksByDay.keys.filter { $0 >= afterWindow }.sorted()
        days = (window + laterDays).map { day in
            Day(day: day, tasks: tasksByDay[day, default: []].sorted { $0.sortIndex < $1.sortIndex })
        }
    }
}
