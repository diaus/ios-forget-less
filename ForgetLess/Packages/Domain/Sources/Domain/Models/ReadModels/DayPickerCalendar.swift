import Foundation

/// The months a Day picker offers, from Today's month on.
public struct DayPickerCalendar: Sendable {
    /// A month of the Day picker.
    public struct Month: Identifiable, Sendable {
        public let firstDay: Date
        /// How many cells come before `firstDay` in its week.
        public let leadingBlankCount: Int
        public let days: [Date]

        public var id: Date { firstDay }

        /// This month's Days in rows of a week, `nil` for each cell before its first Day or after its last.
        public var weeks: [[Date?]] {
            let cells = Array(repeating: nil, count: leadingBlankCount) + days.map(Optional.some)
            return stride(from: 0, to: cells.count, by: Date.daysPerWeek).map { start in
                let week = Array(cells[start..<min(start + Date.daysPerWeek, cells.count)])
                return week + Array(repeating: nil, count: Date.daysPerWeek - week.count)
            }
        }
    }

    /// A Day of each weekday, in the order the header shows them, to be formatted as its weekday.
    public let weekdays: [Date]
    public let months: [Month]

    /// - Parameter firstWeekday: The weekday weeks start on, numbered as `Date.firstWeekday` is.
    public init(today: Date, monthCount: Int, firstWeekday: Int = Date.firstWeekday) {
        let firstMonth = today.firstDayOfMonth
        let weekStart = firstMonth.addingDays(-firstMonth.dayCountIntoWeek(firstWeekday: firstWeekday))
        weekdays = (0..<Date.daysPerWeek).map { weekStart.addingDays($0) }
        months = (0..<monthCount).map { index in
            let firstDay = firstMonth.addingMonths(index)
            let dayCount = firstDay.addingMonths(1).dayCount(from: firstDay)
            return Month(
                firstDay: firstDay,
                leadingBlankCount: firstDay.dayCountIntoWeek(firstWeekday: firstWeekday),
                days: (0..<dayCount).map { firstDay.addingDays($0) }
            )
        }
    }

    /// The week that holds `day`, as a row of its month's `weeks`, or `nil` when no month offered holds it.
    public func week(containing day: Date) -> [Date?]? {
        months.first { $0.days.contains(day) }?.weeks.first { $0.contains(day) }
    }
}
