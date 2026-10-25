import Foundation

/// Converts a Task's Day between its Domain form, local start of day, and its stored form, 00:00 UTC of the same
/// year/month/day (ADR 0001), so a Day never shifts when the time zone changes.
enum DayEncoding {
    // MARK: - Conversions
    static func stored(_ day: Date, calendar: Calendar) -> Date {
        convert(day, from: calendar, to: utc(like: calendar))
    }

    static func day(fromStored stored: Date, calendar: Calendar) -> Date {
        convert(stored, from: utc(like: calendar), to: calendar)
    }

    // MARK: - Helpers
    /// The same calendar system in UTC, so a non-Gregorian calendar names the same year/month/day on both sides.
    private static func utc(like calendar: Calendar) -> Calendar {
        var utc = calendar
        utc.timeZone = .gmt
        return utc
    }

    private static func convert(_ date: Date, from source: Calendar, to target: Calendar) -> Date {
        let components = source.dateComponents([.era, .year, .month, .day], from: date)
        // A year/month/day taken from the same calendar system always names a Day in it.
        return target.date(from: components)!
    }
}
