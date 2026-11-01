import Domain
import Foundation
import Testing

struct DayPickerCalendarTests {
    // MARK: - Tests
    @Test func theMonthsStartWithTodaysMonthAndNumberAsManyAsAskedFor() throws {
        let calendar = DayPickerCalendar(today: try day("2026-08-17"), monthCount: 3, firstWeekday: 2)

        let firstDays = [try day("2026-08-01"), try day("2026-09-01"), try day("2026-10-01")]
        #expect(calendar.months.map(\.firstDay) == firstDays)
    }

    @Test func theMonthsRunOnIntoTheNextYear() throws {
        let calendar = DayPickerCalendar(today: try day("2026-12-31"), monthCount: 3, firstWeekday: 2)

        let firstDays = [try day("2026-12-01"), try day("2027-01-01"), try day("2027-02-01")]
        let lastDays = [try day("2026-12-31"), try day("2027-01-31"), try day("2027-02-28")]
        #expect(calendar.months.map(\.firstDay) == firstDays)
        #expect(calendar.months.map(\.days.last) == lastDays)
    }

    @Test(arguments: [(2, [2, 3, 4, 5, 6, 7, 1]), (1, [1, 2, 3, 4, 5, 6, 7])])
    func theWeekdayHeaderStartsOnTheFirstWeekday(firstWeekday: Int, weekdays: [Int]) throws {
        let calendar = DayPickerCalendar(today: try day("2026-11-17"), monthCount: 1, firstWeekday: firstWeekday)

        #expect(calendar.weekdays.map { Calendar.gmt.component(.weekday, from: $0) } == weekdays)
    }

    // 2026-11-01 is a Sunday and 2026-12-01 a Tuesday.
    @Test(arguments: [(2, [6, 1]), (1, [0, 2])])
    func theBlankCellsBeforeEachMonthsFirstDayFollowTheFirstWeekday(firstWeekday: Int, blankCounts: [Int]) throws {
        let calendar = DayPickerCalendar(today: try day("2026-11-17"), monthCount: 2, firstWeekday: firstWeekday)

        #expect(calendar.months.map(\.leadingBlankCount) == blankCounts)
    }

    @Test(arguments: [
        ("2026-11-17", 30),
        ("2026-12-01", 31),
        ("2028-02-29", 29),
        ("2027-02-10", 28),
    ])
    func aMonthHoldsEachOfItsDaysInOrderFromTheFirst(today: String, dayCount: Int) throws {
        let month = try #require(DayPickerCalendar(today: try day(today), monthCount: 1, firstWeekday: 2).months.first)

        #expect(month.days.map { $0.dayCount(from: month.firstDay) } == Array(0..<dayCount))
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
