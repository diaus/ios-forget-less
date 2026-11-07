import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DateDayFormattingTests {
    // MARK: - Tests
    @Test(arguments: ["2026-10-31", "2026-11-01", "2027-03-02", "2026-10-24", "2026-10-20"])
    func aDayOtherThanTodayOrTomorrowIsNamedByItsShortDate(yearMonthDay: String) throws {
        let today = try day("2026-10-25")
        let otherDay = try day(yearMonthDay)

        #expect(otherDay.relativeNameOrShortDate(today: today) == otherDay.shortDate(today: today))
    }

    @Test func todayAndTomorrowAreEachNamedInAWordOfTheirOwnRatherThanByTheirShortDate() throws {
        let today = try day("2026-10-25")
        let tomorrow = try day("2026-10-26")

        let todayName = today.relativeNameOrShortDate(today: today)
        let tomorrowName = tomorrow.relativeNameOrShortDate(today: today)

        #expect(todayName != today.shortDate(today: today))
        #expect(tomorrowName != tomorrow.shortDate(today: today))
        #expect(todayName != tomorrowName)
    }

    @Test func aDaysFullDateNamesItsYearEvenInTodaysYear() throws {
        let today = try day("2026-10-25")
        let sameYearDay = try day("2026-11-06")

        #expect(sameYearDay.fullDate.contains("2026"))
        #expect(!sameYearDay.shortDate(today: today).contains("2026"))
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
