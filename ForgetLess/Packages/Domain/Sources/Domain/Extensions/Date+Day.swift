import Foundation

public extension Date {
    /// Today: the local year/month/day it is now, as 00:00 GMT (ADR 0001). The one place the local calendar is read.
    static var today: Date {
        Calendar.current.day(containing: .now)
    }

    /// The Day `dayCount` Days after this one, or before it when negative; both 00:00 GMT.
    internal func addingDays(_ dayCount: Int) -> Date {
        // Adding whole Days to a Day always names a Day.
        Calendar.gmt.date(byAdding: .day, value: dayCount, to: self)!
    }

    /// How many Days this Day is after `day`, negative when it's before; both 00:00 GMT.
    func dayCount(from day: Date) -> Int {
        // Two Days are always a whole number of Days apart.
        Calendar.gmt.dateComponents([.day], from: day, to: self).day!
    }

    /// Whether this Day is in the same year as `day`; both 00:00 GMT.
    func isInSameYear(as day: Date) -> Bool {
        Calendar.gmt.isDate(self, equalTo: day, toGranularity: .year)
    }
}
