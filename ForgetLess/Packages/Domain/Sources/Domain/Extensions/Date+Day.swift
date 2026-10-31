import Foundation

public extension Date {
    /// Today, by the device's calendar (ADR 0001).
    static var today: Date {
        Calendar.current.day(containing: .now)
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

    /// Whether this Day is in the same year as `day`.
    func isInSameYear(as day: Date) -> Bool {
        Calendar.gmt.isDate(self, equalTo: day, toGranularity: .year)
    }
}
