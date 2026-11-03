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
        let task = task(on: today.addingDays(5))
        var picker = DayPickerState(task: task, today: today)

        picker.choose(today.addingDays(2))

        #expect(picker.dayToMove(task) == today.addingDays(2))
    }

    @Test func thereIsNoDayToMoveToWhileNothingIsChosen() {
        let task = task(on: today.addingDays(-3))
        let picker = DayPickerState(task: task, today: today)

        #expect(picker.dayToMove(task) == nil)
    }

    @Test func thereIsNoDayToMoveToOnTheTasksOwnDay() {
        let task = task(on: today.addingDays(5))
        var picker = DayPickerState(task: task, today: today)
        #expect(picker.dayToMove(task) == nil)

        picker.choose(today)
        picker.choose(today.addingDays(5))

        #expect(picker.dayToMove(task) == nil)
    }

    @Test func theTasksOwnDayIsTheDayItIsOnNowNotTheOneItOpenedOn() {
        var task = task(on: today.addingDays(5))
        var picker = DayPickerState(task: task, today: today)
        task.day = today.addingDays(2)

        #expect(picker.dayToMove(task) == today.addingDays(5))

        picker.choose(today.addingDays(2))

        #expect(picker.dayToMove(task) == nil)
    }

    // MARK: - Helpers
    private func task(on day: Date) -> TodoTask {
        TodoTask(id: UUID(), name: "Buy milk", day: day, completeDay: nil, sortIndex: 0)
    }
}
