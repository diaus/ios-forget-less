import Domain
import Foundation
import Testing
@testable import Data

/// Moving a Task.
extension TodoTaskRepositoryLiveTests {
    @Test func aTaskMovedToAnotherDayTakesThatDayAndItsPlaceInIt() async throws {
        let container = try Self.inMemoryContainer()
        let day = try Self.day("2026-10-25")
        let nextDay = try Self.day("2026-10-26")
        let moved = Self.task("Pay rent", day: day, sortIndex: 0)
        let first = Self.task("Buy milk", day: nextDay, sortIndex: 3)
        try Self.insert([moved, first, Self.task("Call mum", day: nextDay, sortIndex: 7)], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(id: moved.id, to: MoveDestination(day: nextDay, after: first.id))
        // A fresh repository on the same store, as after a relaunch.
        let nextDaysTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: nextDay)

        #expect(nextDaysTasks.map(\.name) == ["Buy milk", "Pay rent", "Call mum"])
        #expect(nextDaysTasks.map(\.sortIndex) == [0, 1, 2])
        #expect(nextDaysTasks.map(\.day) == [nextDay, nextDay, nextDay])
    }

    @Test func aTaskMovedWithinItsDayChangesOnlyThatDay() async throws {
        let container = try Self.inMemoryContainer()
        let day = try Self.day("2026-10-25")
        let nextDay = try Self.day("2026-10-26")
        let first = Self.task("Buy milk", day: day, sortIndex: 0)
        let moved = Self.task("Pay rent", day: day, sortIndex: 4)
        let nextDays = Self.task("Call mum", day: nextDay, sortIndex: 5)
        try Self.insert([first, Self.task("Walk the dog", day: day, sortIndex: 2), moved, nextDays], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(id: moved.id, to: MoveDestination(day: day, after: first.id))
        let relaunched = TodoTaskRepositoryLive(modelContainer: container)
        let daysTasks = try await relaunched.tasks(on: day)
        let nextDaysTasks = try await relaunched.tasks(on: nextDay)

        #expect(daysTasks.map(\.name) == ["Buy milk", "Pay rent", "Walk the dog"])
        #expect(daysTasks.map(\.sortIndex) == [0, 1, 2])
        #expect(nextDaysTasks == [nextDays])
    }

    @Test func theDayATaskLeftKeepsItsTasksAsTheyWere() async throws {
        let container = try Self.inMemoryContainer()
        let day = try Self.day("2026-10-25")
        let first = Self.task("Buy milk", day: day, sortIndex: 0)
        let moved = Self.task("Pay rent", day: day, sortIndex: 1)
        let last = Self.task("Walk the dog", day: day, sortIndex: 2)
        try Self.insert([first, moved, last], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(id: moved.id, to: MoveDestination(day: try Self.day("2026-10-26"), after: nil))
        let daysTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)

        #expect(daysTasks == [first, last])
    }

    @Test func aMovedCompleteTaskStaysComplete() async throws {
        let container = try Self.inMemoryContainer()
        let today = try Self.day("2026-10-25")
        let tomorrow = try Self.day("2026-10-26")
        var completed = Self.task("Buy milk", day: today, sortIndex: 0)
        completed.completeTime = today
        try Self.insert([completed], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(id: completed.id, to: MoveDestination(day: tomorrow, after: nil))
        let tomorrowsTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: tomorrow)

        #expect(tomorrowsTasks.map(\.id) == [completed.id])
        #expect(tomorrowsTasks.first?.completeTime == today)
    }

    @Test func anOverdueTaskMovedToTodayLeavesOverdue() async throws {
        let container = try Self.inMemoryContainer()
        let today = try Self.day("2026-10-25")
        let overdue = Self.task("Buy milk", day: try Self.day("2026-10-20"), sortIndex: 0)
        let todays = Self.task("Call mum", day: today, sortIndex: 0)
        try Self.insert([overdue, todays], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(id: overdue.id, to: MoveDestination(day: today, after: nil))
        var scheduleTasks = try await repository.scheduleTasks(today: today, historyFirstDay: nil).makeAsyncIterator()

        let tasks = try #require(await scheduleTasks.next())
        #expect(tasks.map(\.name) == ["Buy milk", "Call mum"])
        #expect(tasks.map(\.day) == [today, today])
        #expect(tasks.first?.completeTime == nil)
    }

    @Test func movingATaskThatDoesNotExistChangesNothing() async throws {
        let container = try Self.inMemoryContainer()
        let day = try Self.day("2026-10-25")
        let tasks = [Self.task("Buy milk", day: day, sortIndex: 3), Self.task("Call mum", day: day, sortIndex: 7)]
        try Self.insert(tasks, into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(id: UUID(), to: MoveDestination(day: day, after: nil))
        let daysTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)

        #expect(daysTasks == tasks)
    }

    @Test(.timeLimit(.minutes(1)))
    func scheduleTasksAreSentAgainAfterAMove() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let today = try Self.day("2026-10-25")
        let tomorrow = try Self.day("2026-10-26")
        try await repository.create(name: "Buy milk", day: today)
        var scheduleTasks = try await repository.scheduleTasks(today: today, historyFirstDay: nil).makeAsyncIterator()
        let task = try #require(await scheduleTasks.next()?.first)

        try await repository.move(id: task.id, to: MoveDestination(day: tomorrow, after: nil))

        #expect(await scheduleTasks.next()?.map(\.day) == [tomorrow])
    }
}
