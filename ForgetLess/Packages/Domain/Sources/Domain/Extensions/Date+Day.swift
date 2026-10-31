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
}
