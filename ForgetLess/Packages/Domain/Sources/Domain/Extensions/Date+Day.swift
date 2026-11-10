import Foundation

public extension Date {
    /// Today, by the device's calendar (ADR 0001).
    static var today: Date {
        today(at: .now)
    }

    /// Today as it is at `moment`, by the device's calendar.
    static func today(at moment: Date) -> Date {
        Calendar.user.day(containing: moment)
    }

    /// The moment Today next rolls over after `moment`, by the device's calendar.
    static func nextRollover(after moment: Date) -> Date {
        Calendar.user.nextRollover(after: moment)
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

    /// Whether this Day can be chosen for a Task, which in History is any Day.
    func canBeChosen(today: Date, showsHistory: Bool) -> Bool {
        showsHistory || canBePlanned(today: today)
    }

    /// The Day after this one that can be chosen for a Task: outside History, Today for a Day before Today.
    func nextDayToChoose(today: Date, showsHistory: Bool) -> Date {
        showsHistory ? addingDays(1) : max(addingDays(1), today)
    }

    /// The Day before this one that can be chosen for a Task, or `nil` when there's none: outside History, none
    /// before Today.
    func previousDayToChoose(today: Date, showsHistory: Bool) -> Date? {
        let previousDay = addingDays(-1)
        return previousDay.canBeChosen(today: today, showsHistory: showsHistory) ? previousDay : nil
    }

    func relativeDay(today: Date) -> RelativeDay {
        switch dayCount(from: today) {
        case ..<(-1): .beforeToday
        case -1: .yesterday
        case 0: .today
        case 1: .tomorrow
        default: .later
        }
    }

    /// Whether this Day is in the same year as `day`.
    func isInSameYear(as day: Date) -> Bool {
        Calendar.gmt.isDate(self, equalTo: day, toGranularity: .year)
    }

    /// Runs `operation` with weeks that start on `firstWeekday`, numbered as `Calendar` numbers weekdays (1 is
    /// Sunday), in the Gregorian calendar, so tests don't depend on the machine's region.
    static func withFirstWeekday<Result>(_ firstWeekday: Int, operation: () throws -> Result) rethrows -> Result {
        try Calendar.$user.withValue(.pinned(firstWeekday: firstWeekday), operation: operation)
    }

    /// Runs `operation` with weeks that start on `firstWeekday`, numbered as `Calendar` numbers weekdays (1 is
    /// Sunday), in the Gregorian calendar, so tests don't depend on the machine's region.
    nonisolated(nonsending) static func withFirstWeekday<Result>(
        _ firstWeekday: Int,
        operation: nonisolated(nonsending) () async throws -> Result
    ) async rethrows -> Result {
        try await Calendar.$user.withValue(.pinned(firstWeekday: firstWeekday), operation: operation)
    }

    /// Whether this Day is in the same week as `day`.
    func isInSameWeek(as day: Date) -> Bool {
        let calendar = Calendar.gmt
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

    static let daysPerWeek = 7

    /// How many Days of its week come before this Day.
    internal var dayCountIntoWeek: Int {
        let calendar = Calendar.gmt
        return (calendar.component(.weekday, from: self) - calendar.firstWeekday + Date.daysPerWeek) % Date.daysPerWeek
    }

    /// The first Day of this Day's week.
    internal var firstDayOfWeek: Date {
        addingDays(-dayCountIntoWeek)
    }

    /// The Days from this one up to `end`, `end` left out; none when `end` isn't after this Day.
    internal func days(upTo end: Date) -> [Date] {
        (0..<max(end.dayCount(from: self), 0)).map { addingDays($0) }
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
