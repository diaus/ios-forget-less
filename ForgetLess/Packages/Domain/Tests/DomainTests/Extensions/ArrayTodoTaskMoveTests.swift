import Domain
import Foundation
import Testing

struct ArrayTodoTaskMoveTests {
    // MARK: - Tests
    @Test func aTaskMovedToAnotherDayTakesThatDayAndPlaceAndTheDayIsRenumbered() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Buy milk", day: today, sortIndex: 0),
            task("Call mum", day: today, sortIndex: 1),
            task("Walk the dog", day: tomorrow, sortIndex: 3),
            task("Pay rent", day: tomorrow, sortIndex: 7),
        ]

        let moved = tasks.movingTask(id: tasks[0].id, to: MoveDestination(day: tomorrow, after: tasks[2].id))

        #expect(moved.map(\.name) == ["Call mum", "Walk the dog", "Buy milk", "Pay rent"])
        #expect(moved.map(\.day) == [today, tomorrow, tomorrow, tomorrow])
        #expect(moved.map(\.sortIndex) == [1, 0, 1, 2])
    }

    @Test func aTaskMovedWithinItsDayChangesPlaceOnlyInThatDay() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Buy milk", day: today, sortIndex: 0),
            task("Call mum", day: today, sortIndex: 2),
            task("Walk the dog", day: today, sortIndex: 5),
            task("Pay rent", day: tomorrow, sortIndex: 4),
        ]

        let moved = tasks.movingTask(id: tasks[2].id, to: MoveDestination(day: today, after: nil))

        #expect(moved.map(\.name) == ["Walk the dog", "Buy milk", "Call mum", "Pay rent"])
        #expect(moved.map(\.sortIndex) == [0, 1, 2, 4])
    }

    @Test func aCompleteOverdueTaskMovedToTodayStaysComplete() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let completed = task("Buy milk", day: yesterday, sortIndex: 0, completeDay: today)

        let moved = [completed].movingTask(id: completed.id, to: MoveDestination(day: today, after: nil))

        #expect(moved.map(\.day) == [today])
        #expect(moved.map(\.completeDay) == [today])
    }

    @Test func aTaskMovedToTheEndOfADayGoesAfterEveryTaskThereCompleteOrNot() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Buy milk", day: today, sortIndex: 0),
            task("Walk the dog", day: tomorrow, sortIndex: 0),
            task("Pay rent", day: tomorrow, sortIndex: 1, completeDay: today),
            task("Call mum", day: try day("2026-03-03"), sortIndex: 0),
        ]

        let destination = tasks.destinationAtEnd(of: tomorrow, forTaskWithID: tasks[0].id)
        let moved = tasks.movingTask(id: tasks[0].id, to: destination)

        #expect(moved.map(\.name) == ["Walk the dog", "Pay rent", "Buy milk", "Call mum"])
    }

    @Test func aTaskMovedToTheEndOfAnEmptyDayIsItsOnlyTask() throws {
        let today = try day("2026-03-01")
        let emptyDay = try day("2026-09-02")
        let tasks = [task("Buy milk", day: today, sortIndex: 0)]

        let destination = tasks.destinationAtEnd(of: emptyDay, forTaskWithID: tasks[0].id)

        #expect(destination == MoveDestination(day: emptyDay, after: nil))
    }

    // MARK: - Helpers
    private func task(_ name: String, day: Date, sortIndex: Int, completeDay: Date? = nil) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeDay: completeDay, sortIndex: sortIndex)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
