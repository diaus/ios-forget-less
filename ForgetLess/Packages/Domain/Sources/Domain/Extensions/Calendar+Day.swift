import Foundation

public extension Calendar {
    /// The calendar every Day is reckoned in (ADR 0001).
    static var gmt: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = .gmt
        return calendar
    }

    /// The Day `moment` falls on in this calendar.
    internal func day(containing moment: Date) -> Date {
        var gmt = self
        gmt.timeZone = .gmt
        // A year/month/day taken from the same calendar system always names a Day in it.
        return gmt.date(from: dateComponents([.era, .year, .month, .day], from: moment))!
    }
}
