import Foundation

/// The months a Day picker offers.
public struct DayPickerCalendar: Sendable {
    /// A month of the Day picker.
    public struct Month: Identifiable, Sendable {
        public let firstDay: Date
        /// How many cells come before `firstDay` in its week.
        public let leadingBlankCount: Int
        public let days: [Date]

        /// The month `offset` months after Today's month, which is offset 0, or before it when negative.
        public init(today: Date, offset: Int) {
            firstDay = today.firstDayOfMonth.addingMonths(offset)
            leadingBlankCount = firstDay.dayCountIntoWeek
            let dayCount = firstDay.addingMonths(1).dayCount(from: firstDay)
            days = (0..<dayCount).map(firstDay.addingDays)
        }

        public var id: Date { firstDay }

        /// This month's Days in rows of a week, `nil` for each cell before its first Day or after its last.
        public var weeks: [[Date?]] {
            let cells = Array(repeating: nil, count: leadingBlankCount) + days.map(Optional.some)
            return stride(from: 0, to: cells.count, by: Date.daysPerWeek).map { start in
                let week = Array(cells[start..<min(start + Date.daysPerWeek, cells.count)])
                return week + Array(repeating: nil, count: Date.daysPerWeek - week.count)
            }
        }

        /// `count` rows of a week from the week that holds `firstDay`, every cell a Day, those of the months either
        /// side included.
        public func weeks(count: Int) -> [[Date]] {
            let start = firstDay.addingDays(-leadingBlankCount)
            return (0..<count).map { week in
                (0..<Date.daysPerWeek).map { start.addingDays(week * Date.daysPerWeek + $0) }
            }
        }
    }

    /// The weekday header.
    public let weekdays: [Date]
    public let months: [Month]

    /// `monthCount` months from the month `firstMonthOffset` months after Today's, or before it when negative.
    public init(today: Date, firstMonthOffset: Int = 0, monthCount: Int) {
        weekdays = Self.weekdays()
        months = (firstMonthOffset..<firstMonthOffset + monthCount).map { Month(today: today, offset: $0) }
    }

    /// A Day of each weekday, in the order the header shows them, to be formatted as its weekday.
    public static func weekdays() -> [Date] {
        // Any week holds every weekday once, and the epoch is a Day.
        let weekStart = Date(timeIntervalSince1970: 0).firstDayOfWeek
        return (0..<Date.daysPerWeek).map(weekStart.addingDays)
    }

    /// The week that holds `day`, as a row of its month's `weeks`, or `nil` when no month offered holds it.
    public func week(containing day: Date) -> [Date?]? {
        months.first { $0.days.contains(day) }?.weeks.first { $0.contains(day) }
    }
}
