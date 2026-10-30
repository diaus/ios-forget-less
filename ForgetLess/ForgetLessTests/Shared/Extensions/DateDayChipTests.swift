import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DateDayChipTests {
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

        #expect(try day(yearMonthDay).dayChipCategory(today: today) == category)
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
