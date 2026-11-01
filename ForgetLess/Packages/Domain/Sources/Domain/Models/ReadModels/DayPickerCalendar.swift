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
    }

    /// A Day of each weekday, in the order the header shows them, to be formatted as its weekday.
    public let weekdays: [Date]
    public let months: [Month]

    /// - Parameter firstWeekday: The weekday weeks start on, numbered as `Date.firstWeekday` is.
    public init(today: Date, monthCount: Int, firstWeekday: Int = Date.firstWeekday) {
        let firstMonth = today.firstDayOfMonth
        let weekStart = firstMonth.addingDays(-firstMonth.dayCountIntoWeek(firstWeekday: firstWeekday))
        weekdays = (0..<7).map { weekStart.addingDays($0) }
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
}
