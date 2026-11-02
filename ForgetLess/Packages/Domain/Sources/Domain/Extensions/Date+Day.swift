import Foundation

public extension Date {
    /// Today, by the device's calendar (ADR 0001).
    static var today: Date {
        today(at: .now)
    }

    /// Today as it is at `moment`, by the device's calendar.
    static func today(at moment: Date) -> Date {
        Calendar.current.day(containing: moment)
    }

    /// The moment Today next rolls over after `moment`, by the device's calendar.
    static func nextRollover(after moment: Date) -> Date {
        Calendar.current.nextRollover(after: moment)
    }

    /// The Day `dayCount` Days after this one, or before it when negative.
    func addingDays(_ dayCount: Int) -> Date {
        // Adding whole Days to a Day always names a Day.
        Calendar.gmt.date(byAdding: .day, value: dayCount, to: self)!
    }

    /// How many Days this Day is after `day`, negative when it's before.
    func dayCount(from day: Date) -> Int {
        // Two Days are always a whole number of Days apart.
        Calendar.gmt.dateComponents([.day], from: day, to: self).day!
    }

    /// How many months this Day's month is after `day`'s, negative when it's before.
    func monthCount(from day: Date) -> Int {
        // Two months' first Days are always a whole number of months apart.
        Calendar.gmt.dateComponents([.month], from: day.firstDayOfMonth, to: firstDayOfMonth).month!
    }

    /// Whether a Task can be planned for this Day: never before Today.
    func canBePlanned(today: Date) -> Bool {
        self >= today
    }

    /// The Day after this one that a Task can be planned for, which is Today for a Day before Today.
    func nextDayToPlan(today: Date) -> Date {
        max(addingDays(1), today)
    }

    /// The Day before this one that a Task can be planned for, or `nil` when there's none before Today.
    func previousDayToPlan(today: Date) -> Date? {
        self > today ? addingDays(-1) : nil
    }

    func relativeDay(today: Date) -> RelativeDay {
        switch dayCount(from: today) {
        case ..<0: .beforeToday
        case 0: .today
        case 1: .tomorrow
        default: .later
        }
    }

    /// Whether this Day is in the same year as `day`.
    func isInSameYear(as day: Date) -> Bool {
        Calendar.gmt.isDate(self, equalTo: day, toGranularity: .year)
    }

    /// The weekday the user's weeks start on, numbered as `Calendar` numbers them (1 is Sunday).
    static var firstWeekday: Int {
        Calendar.current.firstWeekday
    }

    /// Whether this Day is in the same week as `day`, for weeks that start on `firstWeekday`.
    func isInSameWeek(as day: Date, firstWeekday: Int) -> Bool {
        var calendar = Calendar.gmt
        calendar.firstWeekday = firstWeekday
        // Every Day falls in a week.
        let weekStart = { (day: Date) in calendar.dateInterval(of: .weekOfYear, for: day)!.start }
        return weekStart(self) == weekStart(day)
    }

    /// Whether this Day is in the same month as `day`, of the same year.
    func isInSameMonth(as day: Date) -> Bool {
        Calendar.gmt.isDate(self, equalTo: day, toGranularity: .month)
    }

    var isFirstDayOfMonth: Bool {
        Calendar.gmt.component(.day, from: self) == 1
    }

    internal static let daysPerWeek = 7

    /// How many Days of its week come before this Day, for weeks that start on `firstWeekday`.
    internal func dayCountIntoWeek(firstWeekday: Int) -> Int {
        (Calendar.gmt.component(.weekday, from: self) - firstWeekday + Date.daysPerWeek) % Date.daysPerWeek
    }

    /// The first Day of this Day's week, for weeks that start on `firstWeekday`.
    internal func firstDayOfWeek(firstWeekday: Int) -> Date {
        addingDays(-dayCountIntoWeek(firstWeekday: firstWeekday))
    }

    /// The 1st of this Day's month.
    internal var firstDayOfMonth: Date {
        // Every Day falls in a month.
        Calendar.gmt.dateInterval(of: .month, for: self)!.start
    }

    /// The Day `monthCount` months after this one, or before it when negative, on the last Day of a shorter month.
    internal func addingMonths(_ monthCount: Int) -> Date {
        // Adding whole months to a Day always names a Day.
        Calendar.gmt.date(byAdding: .month, value: monthCount, to: self)!
    }
}
