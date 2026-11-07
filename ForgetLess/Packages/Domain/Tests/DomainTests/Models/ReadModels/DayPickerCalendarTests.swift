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

    @Test func theMonthsCanStartBeforeTodaysMonthAndRunBackIntoThePreviousYear() throws {
        let today = try day("2026-02-17")
        let calendar = DayPickerCalendar(today: today, firstMonthOffset: -2, monthCount: 4, firstWeekday: 2)

        let firstDays = try ["2025-12-01", "2026-01-01", "2026-02-01", "2026-03-01"].map(day)
        #expect(calendar.months.map(\.firstDay) == firstDays)
        #expect(try calendar.week(containing: day("2025-12-31"))?.contains(day("2025-12-31")) == true)
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

    // 2026-11-01 is a Sunday, so a Monday start leaves six blank cells before it.
    @Test func aMonthsWeeksPadItsFirstAndLastWeekWithBlankCells() throws {
        let calendar = DayPickerCalendar(today: try day("2026-11-17"), monthCount: 1, firstWeekday: 2)
        let month = try #require(calendar.months.first)

        let blanks = { (count: Int) in [Date?](repeating: nil, count: count) }
        #expect(month.weeks.count == 6)
        #expect(try month.weeks.first == blanks(6) + [day("2026-11-01")])
        #expect(month.weeks[1] == (1...7).map { try? day("2026-11-01").addingDays($0) })
        #expect(try month.weeks.last == [day("2026-11-30")] + blanks(6))
    }

    // 2027-02-01 is a Monday, and February 2027 has 28 Days.
    @Test func aMonthThatFillsWholeWeeksHasNoBlankCells() throws {
        let calendar = DayPickerCalendar(today: try day("2027-02-10"), monthCount: 1, firstWeekday: 2)
        let month = try #require(calendar.months.first)

        #expect(month.weeks.count == 4)
        #expect(month.weeks.allSatisfy { $0.count == 7 && !$0.contains(nil) })
        #expect(try month.weeks.first?.first == day("2027-02-01"))
        #expect(try month.weeks.last?.last == day("2027-02-28"))
    }

    @Test func theWeekHoldingADayIsFoundInItsMonth() throws {
        let calendar = DayPickerCalendar(today: try day("2026-11-17"), monthCount: 2, firstWeekday: 2)

        let week = try #require(calendar.week(containing: try day("2026-12-03")))
        // 2026-12-01 is a Tuesday.
        #expect(week == [nil] + (0..<6).map { try? day("2026-12-01").addingDays($0) })
    }

    @Test(arguments: ["2026-10-31", "2027-01-01"])
    func noWeekHoldsADayOutsideTheMonthsShown(yearMonthDay: String) throws {
        let calendar = DayPickerCalendar(today: try day("2026-11-17"), monthCount: 2, firstWeekday: 2)

        #expect(calendar.week(containing: try day(yearMonthDay)) == nil)
    }

    // Offset 0 is Today's month, and later offsets run on into the next years.
    @Test(arguments: [
        (0, "2026-11-01", "2026-11-30"),
        (2, "2027-01-01", "2027-01-31"),
        (15, "2028-02-01", "2028-02-29"),
    ])
    func aMonthAtAnOffsetIsThatManyMonthsAfterTodaysMonth(offset: Int, firstDay: String, lastDay: String) throws {
        let month = DayPickerCalendar.Month(today: try day("2026-11-17"), offset: offset, firstWeekday: 2)

        #expect(try month.firstDay == day(firstDay))
        #expect(try month.days.last == day(lastDay))
    }

    @Test(arguments: [2, 1])
    func aMonthAtAnOffsetIsTheSameMonthTheMonthsShow(firstWeekday: Int) throws {
        let today = try day("2026-11-17")
        let months = DayPickerCalendar(today: today, monthCount: 4, firstWeekday: firstWeekday).months

        for (offset, shown) in months.enumerated() {
            let month = DayPickerCalendar.Month(today: today, offset: offset, firstWeekday: firstWeekday)
            #expect(month.leadingBlankCount == shown.leadingBlankCount)
            #expect(month.days == shown.days)
        }
    }

    @Test(arguments: [(2, [2, 3, 4, 5, 6, 7, 1]), (1, [1, 2, 3, 4, 5, 6, 7])])
    func theWeekdayHeaderStartsOnTheFirstWeekdayWithoutAnyMonth(firstWeekday: Int, weekdays: [Int]) {
        let header = DayPickerCalendar.weekdays(firstWeekday: firstWeekday)

        #expect(header.map { Calendar.gmt.component(.weekday, from: $0) } == weekdays)
    }

    // 2026-12-01 is a Tuesday: a Monday start opens on 2026-11-30, a Sunday start on 2026-11-29.
    @Test(arguments: [(2, "2026-11-30"), (1, "2026-11-29")])
    func aFiveWeekGridStartsOnTheWeekHoldingTheFirstAndRunsOnConsecutiveDays(
        firstWeekday: Int, firstCell: String
    ) throws {
        let month = DayPickerCalendar.Month(today: try day("2026-11-17"), offset: 1, firstWeekday: firstWeekday)

        let weeks = month.weeks(count: 5)

        let start = try day(firstCell)
        #expect(weeks.map(\.count) == [7, 7, 7, 7, 7])
        #expect(weeks.joined().map { $0.dayCount(from: start) } == Array(0..<35))
    }

    // March 2026 runs from a Sunday to a Tuesday, so with a Monday start it spans 6 weeks.
    @Test func aMonthSpanningSixWeeksLosesItsLastRowsDaysToTheNextMonthsGrid() throws {
        let today = try day("2026-03-10")
        let march = DayPickerCalendar.Month(today: today, offset: 0, firstWeekday: 2).weeks(count: 5)
        let april = DayPickerCalendar.Month(today: today, offset: 1, firstWeekday: 2).weeks(count: 5)

        #expect(try march.last?.last == day("2026-03-29"))
        #expect(try april.first?.prefix(2) == [day("2026-03-30"), day("2026-03-31")])
    }

    // 2027-02-01 is a Monday, and February 2027 has 28 Days.
    @Test func aFebruarySpanningFourWeeksGetsMarchsFirstWeekAsItsFifthRow() throws {
        let month = DayPickerCalendar.Month(today: try day("2027-02-10"), offset: 0, firstWeekday: 2)

        let weeks = month.weeks(count: 5)

        let marchFirst = try day("2027-03-01")
        #expect(try weeks.first?.first == day("2027-02-01"))
        #expect(weeks.last == (0..<7).map(marchFirst.addingDays))
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
