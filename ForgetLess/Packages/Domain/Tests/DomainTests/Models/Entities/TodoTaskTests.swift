import Domain
import Foundation
import Testing

struct TodoTaskTests {
    private let day = Date(timeIntervalSinceReferenceDate: 0)

    // MARK: - Tests
    @Test func anEmptyDayStartsAtSortIndexZero() {
        #expect(TodoTask.nextSortIndex(in: []) == 0)
    }

    @Test func theNextTaskGoesAfterTheHighestSortIndexOfItsDay() {
        let tasksOfDay = [task(sortIndex: 4), task(sortIndex: 0), task(sortIndex: 2)]

        #expect(TodoTask.nextSortIndex(in: tasksOfDay) == 5)
    }

    @Test func aTaskNameIsSavedWithoutItsSurroundingWhitespace() {
        #expect(TodoTask.savedName(from: "  Buy milk \n") == "Buy milk")
    }

    @Test func aBlankTaskNameCantBeSaved() {
        #expect(TodoTask.savedName(from: " \n\t") == nil)
    }

    @Test func aTaskMovedAfterATaskInTheMiddleGoesRightAfterIt() {
        let tasksOfDay = [task("Buy milk"), task("Call mum"), task("Walk the dog")]
        let moved = task("Pay rent")

        let order = TodoTask.order(afterMoving: moved, to: destination(after: tasksOfDay[1]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Call mum", "Pay rent", "Walk the dog"])
    }

    @Test func aTaskMovedAfterTheLastTaskGoesToTheEnd() {
        let tasksOfDay = [task("Buy milk"), task("Call mum")]

        let order = TodoTask.order(afterMoving: task("Pay rent"), to: destination(after: tasksOfDay[1]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Call mum", "Pay rent"])
    }

    @Test func aTaskMovedFirstGoesAheadOfEveryTaskOfTheDayCompleteOnesIncluded() {
        let tasksOfDay = [task("Buy milk", completeDay: day), task("Call mum")]

        let order = TodoTask.order(afterMoving: task("Pay rent"), to: destination(after: nil), in: tasksOfDay)

        #expect(order.map(\.name) == ["Pay rent", "Buy milk", "Call mum"])
    }

    @Test func aTaskMovedIntoAnEmptyDayIsItsOnlyTask() {
        let order = TodoTask.order(afterMoving: task("Pay rent"), to: destination(after: nil), in: [])

        #expect(order.map(\.name) == ["Pay rent"])
    }

    @Test func aTaskMovedAfterATaskFollowedByCompleteOnesLandsBeforeThem() {
        let tasksOfDay = [task("Buy milk"), task("Call mum", completeDay: day), task("Walk the dog", completeDay: day)]

        let order = TodoTask.order(afterMoving: task("Pay rent"), to: destination(after: tasksOfDay[0]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Pay rent", "Call mum", "Walk the dog"])
    }

    @Test func aTaskMovedAfterItselfKeepsItsPlace() {
        let tasksOfDay = [task("Buy milk"), task("Call mum"), task("Walk the dog")]

        let order = TodoTask.order(afterMoving: tasksOfDay[1], to: destination(after: tasksOfDay[1]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Call mum", "Walk the dog"])
    }

    @Test func aTaskMovedAfterATaskThatIsNotOnTheDayGoesToTheEnd() {
        let tasksOfDay = [task("Buy milk"), task("Call mum")]
        let deleted = task("Walk the dog")

        let order = TodoTask.order(afterMoving: task("Pay rent"), to: destination(after: deleted), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Call mum", "Pay rent"])
    }

    @Test func aTaskMovedLaterWithinItsDayLeavesItsOldPlace() {
        let tasksOfDay = [task("Buy milk"), task("Call mum"), task("Walk the dog"), task("Pay rent")]

        let order = TodoTask.order(afterMoving: tasksOfDay[0], to: destination(after: tasksOfDay[2]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Call mum", "Walk the dog", "Buy milk", "Pay rent"])
    }

    @Test func aTaskMovedEarlierWithinItsDayLeavesItsOldPlace() {
        let tasksOfDay = [task("Buy milk"), task("Call mum"), task("Walk the dog"), task("Pay rent")]

        let order = TodoTask.order(afterMoving: tasksOfDay[3], to: destination(after: tasksOfDay[0]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Pay rent", "Call mum", "Walk the dog"])
    }

    @Test func theOrderRuleNumbersTheDayFromZeroWithTheMovedTaskOnIt() {
        let tasksOfDay = [task("Buy milk", sortIndex: 3), task("Call mum", sortIndex: 7)]
        let moved = TodoTask(id: UUID(), name: "Pay rent", day: day.addingDays(1), completeDay: nil, sortIndex: 5)

        let order = TodoTask.order(afterMoving: moved, to: destination(after: tasksOfDay[0]), in: tasksOfDay)

        #expect(order.map(\.name) == ["Buy milk", "Pay rent", "Call mum"])
        #expect(order.map(\.sortIndex) == [0, 1, 2])
        #expect(order.allSatisfy { $0.day == day })
    }

    // MARK: - Helpers
    private func task(sortIndex: Int) -> TodoTask {
        TodoTask(id: UUID(), name: "Buy milk", day: day, completeDay: nil, sortIndex: sortIndex)
    }

    private func task(_ name: String, completeDay: Date? = nil, sortIndex: Int = 0) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeDay: completeDay, sortIndex: sortIndex)
    }

    private func destination(after task: TodoTask?) -> MoveDestination {
        MoveDestination(day: day, after: task?.id)
    }
}
