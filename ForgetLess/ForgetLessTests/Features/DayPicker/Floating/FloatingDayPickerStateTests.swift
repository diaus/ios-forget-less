import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct FloatingDayPickerStateTests {
    /// Any Day mid-month, so a few Days either side stay in its month.
    private let today = Date(timeIntervalSince1970: 0).addingDays(14)

    // MARK: - Tests
    @Test(arguments: [(0, 0), (5, 0), (40, 1), (400, 13)])
    func itOpensOnItsDaysMonthWithThatDayChosen(dayCount: Int, monthOffset: Int) {
        let picker = FloatingDayPickerState(today: today, day: today.addingDays(dayCount))

        #expect(picker.monthOffset == monthOffset)
        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -40])
    func withItsDayBeforeTodayItOpensOnTodaysMonthWithNothingChosen(dayCount: Int) {
        let picker = FloatingDayPickerState(today: today, day: today.addingDays(dayCount))

        #expect(picker.monthOffset == 0)
        #expect(picker.chosenDay == nil)
    }

    @Test(arguments: [(-1, false), (-30, false), (0, true), (1, true), (400, true)])
    func onlyADayFromTodayOnCanBeChosen(dayCount: Int, canChoose: Bool) {
        let picker = FloatingDayPickerState(today: today, day: today.addingDays(5))

        #expect(picker.canChoose(today.addingDays(dayCount)) == canChoose)
    }

    @Test(arguments: [(3, 3), (0, 0), (-1, 0), (-12, 0)])
    func itPagesToAnyMonthButNeverBeforeTodays(monthOffset: Int, monthOffsetShown: Int) {
        var picker = FloatingDayPickerState(today: today, day: today.addingDays(40))

        picker.page(to: monthOffset)

        #expect(picker.monthOffset == monthOffsetShown)
    }

    @Test(arguments: [(1, 2), (-1, 0)])
    func itPagesByAMonthEitherWay(monthCount: Int, monthOffsetShown: Int) {
        var picker = FloatingDayPickerState(today: today, day: today.addingDays(40))

        let isPaged = picker.page(by: monthCount)

        #expect(isPaged)
        #expect(picker.monthOffset == monthOffsetShown)
    }

    @Test func pagingBackFromTodaysMonthIsRefused() {
        var picker = FloatingDayPickerState(today: today, day: today)

        let isPaged = picker.page(by: -1)

        #expect(!isPaged)
        #expect(picker.monthOffset == 0)
    }

    @Test(arguments: [0, 1, 40])
    func aChosenDayBecomesItsDay(dayCount: Int) {
        var picker = FloatingDayPickerState(today: today, day: today.addingDays(5))

        let isChosen = picker.choose(today.addingDays(dayCount))

        #expect(isChosen)
        #expect(picker.day == today.addingDays(dayCount))
        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test func aDayBeforeTodayIsRefused() {
        var picker = FloatingDayPickerState(today: today, day: today.addingDays(5))

        let isChosen = picker.choose(today.addingDays(-1))

        #expect(!isChosen)
        #expect(!picker.takesChoice(of: today.addingDays(-1)))
        #expect(picker.chosenDay == today.addingDays(5))
    }

    @Test func onceADayIsChosenAnotherIsRefusedWhileItCloses() {
        var picker = FloatingDayPickerState(today: today, day: today.addingDays(5))
        picker.choose(today.addingDays(1))

        let isChosen = picker.choose(today.addingDays(2))

        #expect(!isChosen)
        #expect(!picker.takesChoice(of: today.addingDays(2)))
        #expect(picker.chosenDay == today.addingDays(1))
    }

    @Test(arguments: [(0, 0), (1, 0), (3, 2)])
    func aNewTodayInTheNextMonthKeepsTheMonthShownButNeverOneBeforeIt(monthOffset: Int, monthOffsetShown: Int) {
        // Today's month's last Day, so the next Day is in the next month.
        let lastDay = today.addingDays(16)
        var picker = FloatingDayPickerState(today: lastDay, day: lastDay)
        picker.page(to: monthOffset)

        picker.update(today: lastDay.addingDays(1))

        #expect(picker.monthOffset == monthOffsetShown)
    }

    @Test func aNewTodayInTheSameMonthKeepsTheMonthShown() {
        var picker = FloatingDayPickerState(today: today, day: today.addingDays(40))

        picker.update(today: today.addingDays(1))

        #expect(picker.monthOffset == 1)
    }

    @Test func aNewTodayStopsChoosingADayItLeavesBeforeIt() {
        var picker = FloatingDayPickerState(today: today, day: today)

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == nil)
        #expect(!picker.canChoose(today))
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
        let picker = FloatingDayPickerState(today: try day(todayYearMonthDay), day: try day(todayYearMonthDay))

        #expect(picker.buttonDays == (try buttonYearMonthDays.map(day)))
    }

    @Test func aPickerThatHidTheKeyboardKeepsSayingSoThroughPagingANewTodayAndAChoice() {
        var picker = FloatingDayPickerState(today: today, day: today)
        #expect(!picker.hasHiddenKeyboard)

        picker.recordHiddenKeyboard()
        picker.page(to: 2)
        picker.update(today: today.addingDays(1))
        picker.choose(today.addingDays(3))

        #expect(picker.hasHiddenKeyboard)
    }

    // MARK: - Helpers
    /// The Day `yyyy-MM-dd`.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
