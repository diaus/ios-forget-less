import Domain
import Foundation
import Testing

struct ArrayTodoTaskMoveStepsTests {
    private let today = Date(timeIntervalSince1970: 1_772_323_200) // 2026-03-01, 00:00 GMT
    private var tomorrow: Date { today.addingDays(1) }

    // MARK: - Tests
    @Test func aStepUpWithinADayGoesAfterTheListedTaskTwoAboveOrFirst() {
        // A Complete Task between them isn't listed, so the steps pass only listed Tasks.
        let tasks = [task("Buy milk", day: today), task("Call mum", day: today), task("Pay rent", day: today)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: false)

        #expect(steps[1].destinationOneStepUp == MoveDestination(day: today, after: nil))
        #expect(steps[2].destinationOneStepUp == MoveDestination(day: today, after: tasks[0].id))
    }

    @Test func aStepDownWithinADayGoesAfterTheListedTaskBelow() {
        let tasks = [task("Buy milk", day: today), task("Call mum", day: today)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: false)

        #expect(steps[0].destinationOneStepDown == MoveDestination(day: today, after: tasks[1].id))
    }

    @Test func theFirstTodayTaskCanNotStepUpIntoOverdue() {
        let tasks = [task("Pay rent", day: today.addingDays(-1)), task("Buy milk", day: today)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: true)

        #expect(steps[1].destinationOneStepUp == nil)
    }

    @Test func theLastTodayTaskStepsDownToFirstOnTomorrowWhileTomorrowIsListed() {
        let tasks = [task("Buy milk", day: today), task("Walk the dog", day: tomorrow)]

        let listed = tasks.oneStepDestinations(today: today, listsTomorrow: true)
        let alone = [tasks[0]].oneStepDestinations(today: today, listsTomorrow: true)
        let unlisted = [tasks[0]].oneStepDestinations(today: today, listsTomorrow: false)

        #expect(listed[0].destinationOneStepDown == MoveDestination(day: tomorrow, after: nil))
        #expect(alone[0].destinationOneStepDown == MoveDestination(day: tomorrow, after: nil))
        #expect(unlisted[0].destinationOneStepDown == nil)
    }

    @Test func theFirstTomorrowTaskStepsUpToLastOnToday() {
        let tasks = [task("Buy milk", day: today), task("Call mum", day: today), task("Walk the dog", day: tomorrow)]
        let withoutToday = [task("Pay rent", day: today.addingDays(-1)), task("Walk the dog", day: tomorrow)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: true)
        let stepsWithoutToday = withoutToday.oneStepDestinations(today: today, listsTomorrow: true)

        #expect(steps[2].destinationOneStepUp == MoveDestination(day: today, after: tasks[1].id))
        #expect(stepsWithoutToday[1].destinationOneStepUp == MoveDestination(day: today, after: nil))
    }

    @Test func theLastTomorrowTaskCanNotStepDown() {
        let tasks = [task("Walk the dog", day: tomorrow)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: true)

        #expect(steps[0].destinationOneStepDown == nil)
    }

    @Test func anOverdueTaskStepsOnlyWithinItsOwnDay() {
        let twoDaysAgo = today.addingDays(-2)
        let yesterday = today.addingDays(-1)
        let tasks = [
            task("Pay rent", day: twoDaysAgo),
            task("Post the letter", day: twoDaysAgo),
            task("Fix the bike", day: yesterday),
            task("Buy milk", day: today),
        ]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: true)

        #expect(steps[0].destinationOneStepUp == nil)
        #expect(steps[0].destinationOneStepDown == MoveDestination(day: twoDaysAgo, after: tasks[1].id))
        #expect(steps[1].destinationOneStepUp == MoveDestination(day: twoDaysAgo, after: nil))
        #expect(steps[1].destinationOneStepDown == nil)
        #expect(steps[2].destinationOneStepUp == nil)
        #expect(steps[2].destinationOneStepDown == nil)
    }

    @Test func theLastRowShownCanNotStepDownPastARowLeftOut() {
        let tasks = [task("Buy milk", day: today), task("Call mum", day: today)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: true)

        #expect(steps[0].destinationOneStepDown != nil)
        #expect(steps[0].destinationOneStepDownFromLastShownRow == nil)
    }

    @Test func theLastRowShownStillStepsDownToTomorrowInItsOwnPlace() {
        let tasks = [task("Buy milk", day: today), task("Walk the dog", day: tomorrow)]

        let steps = tasks.oneStepDestinations(today: today, listsTomorrow: true)

        #expect(steps[0].destinationOneStepDownFromLastShownRow == MoveDestination(day: tomorrow, after: nil))
    }

    // MARK: - Helpers
    private func task(_ name: String, day: Date) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeDay: nil, sortIndex: 0)
    }
}
