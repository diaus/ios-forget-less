import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DateDayFormattingTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 2 * 3600)!
        return calendar
    }()

    // MARK: - Tests
    @Test(arguments: [
        ("2026-01-01", false),
        ("2026-12-31", false),
        ("2027-01-01", true),
        ("2025-12-31", true),
    ])
    func aShortDateShowsTheYearOnlyWhenTheDayIsOutsideTodaysYear(yearMonthDay: String, showsYear: Bool) throws {
        let today = try day("2026-10-25")

        #expect(try day(yearMonthDay).shortDateShowsYear(today: today, calendar: calendar) == showsYear)
    }

    // MARK: - Helpers
    /// Local midnight of `yyyy-MM-dd` in the suite's UTC+2 calendar.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00+02:00", strategy: .iso8601)
    }
}
