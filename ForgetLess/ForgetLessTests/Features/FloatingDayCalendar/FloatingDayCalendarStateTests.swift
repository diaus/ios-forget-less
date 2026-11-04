import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct FloatingDayCalendarStateTests {
    /// Any Day mid-month, so a few Days either side stay in its month.
    private let today = Date(timeIntervalSince1970: 0).addingDays(14)

    // MARK: - Tests
    @Test(arguments: [(0, 0), (5, 0), (40, 1), (400, 13)])
    func itOpensOnItsDaysMonthWithThatDayChosen(dayCount: Int, monthOffset: Int) {
        let calendar = FloatingDayCalendarState(today: today, day: today.addingDays(dayCount))

        #expect(calendar.monthOffset == monthOffset)
        #expect(calendar.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -40])
    func withItsDayBeforeTodayItOpensOnTodaysMonthWithNothingChosen(dayCount: Int) {
        let calendar = FloatingDayCalendarState(today: today, day: today.addingDays(dayCount))

        #expect(calendar.monthOffset == 0)
        #expect(calendar.chosenDay == nil)
    }

    @Test(arguments: [(-1, false), (-30, false), (0, true), (1, true), (400, true)])
    func onlyADayFromTodayOnCanBeChosen(dayCount: Int, canChoose: Bool) {
        let calendar = FloatingDayCalendarState(today: today, day: today.addingDays(5))

        #expect(calendar.canChoose(today.addingDays(dayCount)) == canChoose)
    }

    @Test(arguments: [(3, 3), (0, 0), (-1, 0), (-12, 0)])
    func itPagesToAnyMonthButNeverBeforeTodays(monthOffset: Int, monthOffsetShown: Int) {
        var calendar = FloatingDayCalendarState(today: today, day: today.addingDays(40))

        calendar.page(to: monthOffset)

        #expect(calendar.monthOffset == monthOffsetShown)
    }

    @Test(arguments: [(1, 2), (-1, 0)])
    func itPagesByAMonthEitherWay(monthCount: Int, monthOffsetShown: Int) {
        var calendar = FloatingDayCalendarState(today: today, day: today.addingDays(40))

        let isPaged = calendar.page(by: monthCount)

        #expect(isPaged)
        #expect(calendar.monthOffset == monthOffsetShown)
    }

    @Test func pagingBackFromTodaysMonthIsRefused() {
        var calendar = FloatingDayCalendarState(today: today, day: today)

        let isPaged = calendar.page(by: -1)

        #expect(!isPaged)
        #expect(calendar.monthOffset == 0)
    }

    @Test(arguments: [0, 1, 40])
    func aChosenDayBecomesItsDay(dayCount: Int) {
        var calendar = FloatingDayCalendarState(today: today, day: today.addingDays(5))

        let isChosen = calendar.choose(today.addingDays(dayCount))

        #expect(isChosen)
        #expect(calendar.day == today.addingDays(dayCount))
        #expect(calendar.chosenDay == today.addingDays(dayCount))
    }

    @Test func aDayBeforeTodayIsRefused() {
        var calendar = FloatingDayCalendarState(today: today, day: today.addingDays(5))

        let isChosen = calendar.choose(today.addingDays(-1))

        #expect(!isChosen)
        #expect(!calendar.takesChoice(of: today.addingDays(-1)))
        #expect(calendar.chosenDay == today.addingDays(5))
    }

    @Test func onceADayIsChosenAnotherIsRefusedWhileItCloses() {
        var calendar = FloatingDayCalendarState(today: today, day: today.addingDays(5))
        calendar.choose(today.addingDays(1))

        let isChosen = calendar.choose(today.addingDays(2))

        #expect(!isChosen)
        #expect(!calendar.takesChoice(of: today.addingDays(2)))
        #expect(calendar.chosenDay == today.addingDays(1))
    }

    @Test(arguments: [(0, 0), (1, 0), (3, 2)])
    func aNewTodayInTheNextMonthKeepsTheMonthShownButNeverOneBeforeIt(monthOffset: Int, monthOffsetShown: Int) {
        // Today's month's last Day, so the next Day is in the next month.
        let lastDay = today.addingDays(16)
        var calendar = FloatingDayCalendarState(today: lastDay, day: lastDay)
        calendar.page(to: monthOffset)

        calendar.update(today: lastDay.addingDays(1))

        #expect(calendar.monthOffset == monthOffsetShown)
    }

    @Test func aNewTodayInTheSameMonthKeepsTheMonthShown() {
        var calendar = FloatingDayCalendarState(today: today, day: today.addingDays(40))

        calendar.update(today: today.addingDays(1))

        #expect(calendar.monthOffset == 1)
    }

    @Test func aNewTodayStopsChoosingADayItLeavesBeforeIt() {
        var calendar = FloatingDayCalendarState(today: today, day: today)

        calendar.update(today: today.addingDays(1))

        #expect(calendar.chosenDay == nil)
        #expect(!calendar.canChoose(today))
    }

    @Test(arguments: [
        ("2026-11-02", ["2026-11-02", "2026-11-03", "2026-11-04"]),
        ("2026-11-29", ["2026-11-29", "2026-11-30", "2026-12-01"]),
        ("2026-11-30", ["2026-11-30", "2026-12-01", "2026-12-02"]),
        ("2026-12-31", ["2026-12-31", "2027-01-01", "2027-01-02"]),
    ])
    func theButtonsDaysAreTodayTomorrowAndTheDayAfterTomorrow(
        todayYearMonthDay: String,
        buttonYearMonthDays: [String]
    ) throws {
        let calendar = FloatingDayCalendarState(today: try day(todayYearMonthDay), day: try day(todayYearMonthDay))

        #expect(calendar.buttonDays == (try buttonYearMonthDays.map(day)))
    }

    @Test func aCalendarThatHidTheKeyboardKeepsSayingSoThroughPagingANewTodayAndAChoice() {
        var calendar = FloatingDayCalendarState(today: today, day: today)
        #expect(!calendar.hasHiddenKeyboard)

        calendar.recordHiddenKeyboard()
        calendar.page(to: 2)
        calendar.update(today: today.addingDays(1))
        calendar.choose(today.addingDays(3))

        #expect(calendar.hasHiddenKeyboard)
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
