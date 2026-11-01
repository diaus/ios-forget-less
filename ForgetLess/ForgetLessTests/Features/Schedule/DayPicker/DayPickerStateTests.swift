import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DayPickerStateTests {
    /// Any Day: the rules read Days only against it.
    private let today = Date(timeIntervalSince1970: 0)

    // MARK: - Tests
    @Test(arguments: [0, 1, 40])
    func itOpensWithTheTasksDayChosen(dayCount: Int) {
        let picker = DayPickerState(task: task(on: today.addingDays(dayCount)), today: today)

        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -30])
    func anOverdueTaskOpensWithNothingChosen(dayCount: Int) {
        let picker = DayPickerState(task: task(on: today.addingDays(dayCount)), today: today)

        #expect(picker.chosenDay == nil)
    }

    @Test(arguments: [0, 1, 400])
    func aDayFromTodayOnIsChosen(dayCount: Int) {
        var picker = DayPickerState(task: task(on: today.addingDays(5)), today: today)

        picker.choose(today.addingDays(dayCount))

        #expect(picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test(arguments: [-1, -30])
    func aDayBeforeTodayIsRefused(dayCount: Int) {
        var picker = DayPickerState(task: task(on: today.addingDays(5)), today: today)

        picker.choose(today.addingDays(dayCount))

        #expect(!picker.canChoose(today.addingDays(dayCount)))
        #expect(picker.chosenDay == today.addingDays(5))
    }

    @Test func aNewTodayClearsAChosenDayItLeavesBeforeIt() {
        var picker = DayPickerState(task: task(on: today.addingDays(5)), today: today)
        picker.choose(today)

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == nil)
        #expect(!picker.canChoose(today))
    }

    @Test(arguments: [1, 5])
    func aNewTodayKeepsAChosenDayOnOrAfterIt(dayCount: Int) {
        var picker = DayPickerState(task: task(on: today.addingDays(5)), today: today)
        picker.choose(today.addingDays(dayCount))

        picker.update(today: today.addingDays(1))

        #expect(picker.chosenDay == today.addingDays(dayCount))
    }

    @Test func theChosenDayIsTheDayToMoveTo() {
        var picker = DayPickerState(task: task(on: today.addingDays(5)), today: today)

        picker.choose(today.addingDays(2))

        #expect(picker.dayToMoveTo == today.addingDays(2))
    }

    @Test func thereIsNoDayToMoveToWhileNothingIsChosen() {
        let picker = DayPickerState(task: task(on: today.addingDays(-3)), today: today)

        #expect(picker.dayToMoveTo == nil)
    }

    @Test func thereIsNoDayToMoveToOnTheTasksOwnDay() {
        var picker = DayPickerState(task: task(on: today.addingDays(5)), today: today)
        #expect(picker.dayToMoveTo == nil)

        picker.choose(today)
        picker.choose(today.addingDays(5))

        #expect(picker.dayToMoveTo == nil)
    }

    // MARK: - Helpers
    private func task(on day: Date) -> TodoTask {
        TodoTask(id: UUID(), name: "Buy milk", day: day, completeDay: nil, sortIndex: 0)
    }
}
