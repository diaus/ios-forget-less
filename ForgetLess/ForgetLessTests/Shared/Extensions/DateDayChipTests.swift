import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DateDayChipTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 2 * 3600)!
        return calendar
    }()

    // MARK: - Tests
    @Test(arguments: [
        ("2026-10-25", DayChipCategory.today),
        ("2026-10-26", .tomorrow),
        ("2026-10-31", .weekday),
        ("2026-11-01", .later),
        ("2026-10-24", .past),
    ])
    func aDayChipIsCategorisedByTheDayRelativeToToday(yearMonthDay: String, category: DayChipCategory) throws {
        let today = try day("2026-10-25")

        #expect(try day(yearMonthDay).dayChipCategory(today: today, calendar: calendar) == category)
    }

    // MARK: - Helpers
    /// Local midnight of `yyyy-MM-dd` in the suite's UTC+2 calendar.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00+02:00", strategy: .iso8601)
    }
}
