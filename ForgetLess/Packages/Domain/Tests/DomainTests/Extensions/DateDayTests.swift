import Domain
import Foundation
import Testing

struct DateDayTests {
    // MARK: - Tests
    @Test(arguments: [
        ("2026-10-25", 0),
        ("2026-10-26", 1),
        ("2026-10-24", -1),
        ("2026-11-01", 7),
        ("2027-01-01", 68),
    ])
    func aDayCountsWholeDaysFromAnotherDay(yearMonthDay: String, dayCount: Int) throws {
        #expect(try day(yearMonthDay).dayCount(from: try day("2026-10-25")) == dayCount)
    }

    @Test(arguments: [
        ("2026-01-01", true),
        ("2026-12-31", true),
        ("2027-01-01", false),
        ("2025-12-31", false),
    ])
    func aDayIsInTheSameYearOnlyWithinThatYear(yearMonthDay: String, isInSameYear: Bool) throws {
        #expect(try day(yearMonthDay).isInSameYear(as: try day("2026-10-25")) == isInSameYear)
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
