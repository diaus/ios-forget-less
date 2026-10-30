import Foundation

public extension Calendar {
    /// The calendar every Day is reckoned in: the current calendar in GMT, where a Day is 00:00 of its year/month/day
    /// (ADR 0001).
    static var gmt: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = .gmt
        return calendar
    }

    /// The Day `moment` falls on in this calendar, as 00:00 GMT of that year/month/day.
    internal func day(containing moment: Date) -> Date {
        var gmt = self
        gmt.timeZone = .gmt
        // A year/month/day taken from the same calendar system always names a Day in it.
        return gmt.date(from: dateComponents([.era, .year, .month, .day], from: moment))!
    }
}
