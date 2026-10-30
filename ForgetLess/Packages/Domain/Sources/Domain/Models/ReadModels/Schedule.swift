import Foundation

/// What the Schedule screen lists: one entry per Day from Today through Today + 99, empty or not, then one for each
/// later Day that has Tasks.
public struct Schedule: Sendable {
    /// A Day of the Schedule and its Tasks.
    public struct Day: Identifiable, Sendable {
        /// The Day, as 00:00 GMT.
        public let day: Date
        public let tasks: [TodoTask]

        public var id: Date { day }
    }

    /// The Days in order.
    public let days: [Day]

    /// How many Days the window holds, Today included.
    private static let windowDayCount = 100

    /// Builds the Schedule from `tasks`, with `today` as 00:00 GMT.
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
