import Foundation

/// What the Schedule screen lists: one entry per Day from Today through Today + 99, empty or not, then one for each
/// later Day that has Tasks.
public struct Schedule: Sendable {
    /// A Day of the Schedule and its Tasks.
    public struct Day: Identifiable, Sendable {
        /// The Day, as local start of day.
        public let day: Date
        public let tasks: [TodoTask]

        public var id: Date { day }
    }

    /// The Days in order.
    public let days: [Day]

    /// How many Days the window holds, Today included.
    private static let windowDayCount = 100

    /// Builds the Schedule from `tasks`, with `today` as a local start of day in `calendar`.
    public init(tasks: [TodoTask], today: Date, calendar: Calendar) {
        let tasksByDay = Dictionary(grouping: tasks) { calendar.startOfDay(for: $0.day) }
        let window = (0..<Self.windowDayCount).map { calendar.day(byAdding: $0, to: today) }
        let afterWindow = calendar.day(byAdding: Self.windowDayCount, to: today)
        let laterDays = tasksByDay.keys.filter { $0 >= afterWindow }.sorted()
        days = (window + laterDays).map { day in
            Day(day: day, tasks: tasksByDay[day, default: []].sorted { $0.sortIndex < $1.sortIndex })
        }
    }
}

// MARK: - Helpers
private extension Calendar {
    func day(byAdding dayCount: Int, to day: Date) -> Date {
        // Adding whole Days to a Day always names a Day.
        startOfDay(for: date(byAdding: .day, value: dayCount, to: day)!)
    }
}
