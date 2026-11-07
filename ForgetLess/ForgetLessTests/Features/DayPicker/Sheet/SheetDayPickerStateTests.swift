import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct SheetDayPickerStateTests {
    /// Any Day: the rules read Days only against it.
    private let today = Date(timeIntervalSince1970: 0)

    // MARK: - Tests
    @Test(arguments: [0, 1, 40])
    func itOpensWithItsDayChosen(dayCount: Int) {
        let picker = sheetDayPicker(on: today.addingDays(dayCount))

        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -30])
    func itOpensWithNothingChosenOnADayBeforeToday(dayCount: Int) {
        let picker = sheetDayPicker(on: today.addingDays(dayCount))

        #expect(picker.chosenDay == nil)
    }

    @Test(arguments: [0, 1, 400])
    func aDayFromTodayOnIsChosen(dayCount: Int) {
        var picker = sheetDayPicker(on: today.addingDays(5))

        picker.choose(today.addingDays(dayCount))

        #expect(picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -30])
    func aDayBeforeTodayIsRefused(dayCount: Int) {
        var picker = sheetDayPicker(on: today.addingDays(5))

        picker.choose(today.addingDays(dayCount))

        #expect(!picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.chosenDay == today.addingDays(5))
    }

    @Test func aNewTodayClearsAChosenDayItLeavesBeforeIt() {
        var picker = sheetDayPicker(on: today.addingDays(5))
        picker.choose(today)

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == nil)
        #expect(!picker.canChoose(today))
    }

    @Test(arguments: [1, 5])
    func aNewTodayKeepsAChosenDayOnOrAfterIt(dayCount: Int) {
        var picker = sheetDayPicker(on: today.addingDays(5))
        picker.choose(today.addingDays(dayCount))

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test func theChosenDayIsTheDayToMoveTo() {
        var picker = sheetDayPicker(on: today.addingDays(5))

        picker.choose(today.addingDays(2))

        #expect(picker.dayToMove == today.addingDays(2))
    }

    @Test func thereIsNoDayToMoveToWhileNothingIsChosen() {
        let picker = sheetDayPicker(on: today.addingDays(-3))

        #expect(picker.dayToMove == nil)
    }

    @Test func thereIsNoDayToMoveToOnTheDayItOpenedOn() {
        var picker = sheetDayPicker(on: today.addingDays(5))
        #expect(picker.dayToMove == nil)

        picker.choose(today)
        picker.choose(today.addingDays(5))

        #expect(picker.dayToMove == nil)
    }

    @Test func outsideHistoryItOffersNoMonthBeforeTodays() {
        let picker = sheetDayPicker(on: today.addingDays(-40))

        #expect(picker.monthOffsets.lowerBound == 0)
    }

    @Test(arguments: [-1, -40, -4000])
    func inHistoryItOpensWithAPastDayChosenAndOffersItsMonth(dayCount: Int) {
        let day = today.addingDays(dayCount)
        let picker = sheetDayPicker(on: day, showsHistory: true)

        #expect(picker.chosenDay == day)
        #expect(picker.monthOffsets.contains(day.monthCount(from: today)))
    }

    @Test(arguments: [-1, -400])
    func inHistoryAPastDayIsChosenAsTheDayToMoveTo(dayCount: Int) {
        var picker = sheetDayPicker(on: today.addingDays(5), showsHistory: true)

        picker.choose(today.addingDays(dayCount))

        #expect(picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.dayToMove == today.addingDays(dayCount))
    }

    @Test func inHistoryANewTodayKeepsAChosenDayItLeavesBeforeIt() {
        var picker = sheetDayPicker(on: today.addingDays(5), showsHistory: true)
        picker.choose(today)

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == today)
    }

    // MARK: - Helpers
    private func sheetDayPicker(on day: Date, showsHistory: Bool = false) -> SheetDayPickerState {
        SheetDayPickerState(day: day, today: today, target: .composer, showsHistory: showsHistory)
    }
}
