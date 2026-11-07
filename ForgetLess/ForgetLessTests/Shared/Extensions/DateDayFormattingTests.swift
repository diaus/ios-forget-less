import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DateDayFormattingTests {
    // MARK: - Tests
    @Test(arguments: ["2026-10-31", "2026-11-01", "2027-03-02", "2026-10-23", "2026-10-20"])
    func aDayOtherThanYesterdayTodayOrTomorrowIsNamedByItsShortDate(yearMonthDay: String) throws {
        let today = try day("2026-10-25")
        let otherDay = try day(yearMonthDay)

        #expect(otherDay.relativeNameOrShortDate(today: today) == otherDay.shortDate(today: today))
    }

    @Test func yesterdayTodayAndTomorrowAreEachNamedInAWordOfTheirOwnRatherThanByTheirShortDate() throws {
        let today = try day("2026-10-25")
        let days = [try day("2026-10-24"), today, try day("2026-10-26")]

        let names = days.map { $0.relativeNameOrShortDate(today: today) }

        for (day, name) in zip(days, names) {
            #expect(name != day.shortDate(today: today))
        }
        #expect(Set(names).count == days.count)
    }

    @Test func yesterdaysHeaderNamesItInItsWord() throws {
        let today = try day("2026-10-25")
        let yesterday = try day("2026-10-24")

        let name = try #require(yesterday.relativeName(today: today))

        #expect(yesterday.dayHeader(today: today).contains(name))
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
