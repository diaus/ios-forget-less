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

    @Test(arguments: [
        // 2026-11-01 is a Sunday.
        ("2026-11-01", "2026-11-02", 1, true),
        ("2026-11-01", "2026-11-02", 2, false),
        ("2026-10-31", "2026-11-01", 1, false),
        ("2026-10-31", "2026-11-01", 2, true),
        ("2026-11-02", "2026-11-08", 2, true),
        ("2026-11-02", "2026-11-09", 2, false),
        ("2026-12-31", "2027-01-01", 1, true),
        ("2026-12-31", "2027-01-01", 2, true),
    ])
    func aDayIsInTheSameWeekOnlyUntilTheFirstWeekdayComesRound(
        yearMonthDay: String,
        other: String,
        firstWeekday: Int,
        isInSameWeek: Bool
    ) throws {
        #expect(try day(yearMonthDay).isInSameWeek(as: try day(other), firstWeekday: firstWeekday) == isInSameWeek)
    }

    @Test(arguments: [
        ("2026-10-01", true),
        ("2026-10-31", true),
        ("2026-11-01", false),
        ("2025-10-25", false),
    ])
    func aDayIsInTheSameMonthOnlyWithinThatMonthOfThatYear(yearMonthDay: String, isInSameMonth: Bool) throws {
        #expect(try day(yearMonthDay).isInSameMonth(as: try day("2026-10-25")) == isInSameMonth)
    }

    @Test(arguments: [
        ("2026-11-01", true),
        ("2027-01-01", true),
        ("2026-11-02", false),
        ("2026-10-31", false),
    ])
    func onlyTheFirstOfAMonthIsItsFirstDay(yearMonthDay: String, isFirstDayOfMonth: Bool) throws {
        #expect(try day(yearMonthDay).isFirstDayOfMonth == isFirstDayOfMonth)
    }

    @Test(arguments: [
        ("2026-10-24", "2026-10-25", RelativeDay.beforeToday),
        ("2025-03-01", "2026-10-25", RelativeDay.beforeToday),
        ("2026-10-25", "2026-10-25", RelativeDay.today),
        ("2026-10-26", "2026-10-25", RelativeDay.tomorrow),
        ("2026-10-27", "2026-10-25", RelativeDay.later),
        ("2026-12-31", "2027-01-01", RelativeDay.beforeToday),
        ("2027-01-01", "2026-12-31", RelativeDay.tomorrow),
        ("2027-01-02", "2026-12-31", RelativeDay.later),
    ])
    func aDaySitsBeforeTodayOnTodayOnTomorrowOrLater(
        yearMonthDay: String,
        today: String,
        relativeDay: RelativeDay
    ) throws {
        #expect(try day(yearMonthDay).relativeDay(today: try day(today)) == relativeDay)
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
