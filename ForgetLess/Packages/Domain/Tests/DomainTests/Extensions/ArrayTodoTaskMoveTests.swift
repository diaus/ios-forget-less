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
        let completed = task("Buy milk", day: yesterday, sortIndex: 0, completeTime: today)

        let moved = [completed].movingTask(id: completed.id, to: MoveDestination(day: today, after: nil))

        #expect(moved.map(\.day) == [today])
        #expect(moved.map(\.completeTime) == [today])
    }

    @Test func aTaskMovedToTheEndOfADayGoesAfterEveryTaskThereCompleteOrNot() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Buy milk", day: today, sortIndex: 0),
            task("Walk the dog", day: tomorrow, sortIndex: 0),
            task("Pay rent", day: tomorrow, sortIndex: 1, completeTime: today),
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

    @Test func tasksMovedToTheTopOfADayGoThereInTheOrderGivenAndTheListStaysInOrder() throws {
        let lastWeek = try day("2026-02-22")
        let yesterday = try day("2026-02-28")
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Book a flight", day: lastWeek, sortIndex: 4),
            task("Completed from Overdue", day: lastWeek, sortIndex: 5, completeTime: today),
            task("Pay rent", day: yesterday, sortIndex: 1),
            task("Buy milk", day: today, sortIndex: 0),
            task("Walk the dog", day: tomorrow, sortIndex: 2),
            task("Call mum", day: tomorrow, sortIndex: 6, completeTime: today),
        ]

        let moved = tasks.movingTasks(ids: [tasks[0].id, tasks[2].id], toStartOf: tomorrow)

        #expect(moved.map(\.name) == [
            "Completed from Overdue", "Buy milk", "Book a flight", "Pay rent", "Walk the dog", "Call mum",
        ])
        #expect(moved.map(\.day) == [lastWeek, today, tomorrow, tomorrow, tomorrow, tomorrow])
        #expect(moved.map(\.sortIndex) == [5, 0, 0, 1, 2, 3])
    }

    @Test func movingTasksToTheTopOfADaySkipsIDsWithNoTask() throws {
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Buy milk", day: try day("2026-02-28"), sortIndex: 2),
            task("Call mum", day: tomorrow, sortIndex: 3),
        ]

        let moved = tasks.movingTasks(ids: [UUID()], toStartOf: tomorrow)

        #expect(moved == tasks)
    }

    // MARK: - Helpers
    private func task(_ name: String, day: Date, sortIndex: Int, completeTime: Date? = nil) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeTime: completeTime, sortIndex: sortIndex)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
