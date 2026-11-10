import Foundation

public extension Calendar {
    /// The calendar every Day is reckoned in (ADR 0001).
    static var gmt: Calendar {
        var calendar = Calendar.user
        calendar.timeZone = .gmt
        return calendar
    }

    // Auto-updating, since this default is made once and must follow the user's later changes to their settings.
    /// The user's calendar: the device's, or the one a test pins with `Date.withFirstWeekday`.
    @TaskLocal internal static var user: Calendar = .autoupdatingCurrent

    /// A Gregorian calendar whose weeks start on `firstWeekday`, the same on any machine.
    internal static func pinned(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    /// The Day `moment` falls on in this calendar.
    internal func day(containing moment: Date) -> Date {
        var gmt = self
        gmt.timeZone = .gmt
        // A year/month/day taken from the same calendar system always names a Day in it.
        return gmt.date(from: dateComponents([.era, .year, .month, .day], from: moment))!
    }

    /// The moment Today next rolls over after `moment`, in this calendar.
    internal func nextRollover(after moment: Date) -> Date {
        // Every moment falls in a day, which has an end.
        dateInterval(of: .day, for: moment)!.end
    }
}
