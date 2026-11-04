import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DayPickerStateTests {
    /// Any Day: the rules read Days only against it.
    private let today = Date(timeIntervalSince1970: 0)

    @Test(arguments: [0, 1, 40])
    func itOpensWithItsDayChosen(dayCount: Int) {
        let picker = DayPickerState(day: today.addingDays(dayCount), today: today, target: .composer)

        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -30])
    func itOpensWithNothingChosenOnADayBeforeToday(dayCount: Int) {
        let picker = DayPickerState(day: today.addingDays(dayCount), today: today, target: .composer)

        #expect(picker.chosenDay == nil)
    }

    @Test(arguments: [0, 1, 400])
    func aDayFromTodayOnIsChosen(dayCount: Int) {
        var picker = DayPickerState(day: today.addingDays(5), today: today, target: .composer)

        picker.choose(today.addingDays(dayCount))

        #expect(picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -30])
    func aDayBeforeTodayIsRefused(dayCount: Int) {
        var picker = DayPickerState(day: today.addingDays(5), today: today, target: .composer)

        picker.choose(today.addingDays(dayCount))

        #expect(!picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.chosenDay == today.addingDays(5))
    }

    @Test func aNewTodayClearsAChosenDayItLeavesBeforeIt() {
        var picker = DayPickerState(day: today.addingDays(5), today: today, target: .composer)
        picker.choose(today)

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == nil)
        #expect(!picker.canChoose(today))
    }

    @Test(arguments: [1, 5])
    func aNewTodayKeepsAChosenDayOnOrAfterIt(dayCount: Int) {
        var picker = DayPickerState(day: today.addingDays(5), today: today, target: .composer)
        picker.choose(today.addingDays(dayCount))

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test func theChosenDayIsTheDayToMoveTo() {
        var picker = DayPickerState(day: today.addingDays(5), today: today, target: .composer)

        picker.choose(today.addingDays(2))

        #expect(picker.dayToMove == today.addingDays(2))
    }

    @Test func thereIsNoDayToMoveToWhileNothingIsChosen() {
        let picker = DayPickerState(day: today.addingDays(-3), today: today, target: .composer)

        #expect(picker.dayToMove == nil)
    }

    @Test func thereIsNoDayToMoveToOnTheDayItOpenedOn() {
        var picker = DayPickerState(day: today.addingDays(5), today: today, target: .composer)
        #expect(picker.dayToMove == nil)

        picker.choose(today)
        picker.choose(today.addingDays(5))

        #expect(picker.dayToMove == nil)
    }
}
