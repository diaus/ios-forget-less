import Domain
import FactoryKit
import FactoryTesting
import Foundation
import Synchronization
import Testing
@testable import Data

/// Moving several Tasks to the top of a Day at once.
extension TodoTaskRepositoryLiveTests {
    @Test func tasksMovedToTheTopOfADayGoAboveItsTasksInTheOrderGiven() async throws {
        let container = try Self.inMemoryContainer()
        let lastWeek = try Self.day("2026-10-18")
        let yesterday = try Self.day("2026-10-24")
        let tomorrow = try Self.day("2026-10-26")
        let bookAFlight = Self.task("Book a flight", day: lastWeek, sortIndex: 4)
        let payRent = Self.task("Pay rent", day: yesterday, sortIndex: 1)
        var callMum = Self.task("Call mum", day: tomorrow, sortIndex: 6)
        callMum.completeTime = yesterday
        let buyMilk = Self.task("Buy milk", day: tomorrow, sortIndex: 2)
        try Self.insert([bookAFlight, payRent, buyMilk, callMum], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(ids: [bookAFlight.id, payRent.id], toStartOf: tomorrow)
        // A fresh repository on the same store, as after a relaunch.
        let tomorrowsTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: tomorrow)

        #expect(tomorrowsTasks.map(\.name) == ["Book a flight", "Pay rent", "Buy milk", "Call mum"])
        #expect(tomorrowsTasks.map(\.sortIndex) == [0, 1, 2, 3])
        #expect(tomorrowsTasks.map(\.completeTime) == [nil, nil, nil, yesterday])
    }

    @Test func theDaysTheMovedTasksLeftKeepTheirOtherTasksAsTheyWere() async throws {
        let container = try Self.inMemoryContainer()
        let yesterday = try Self.day("2026-10-24")
        let first = Self.task("Buy milk", day: yesterday, sortIndex: 0)
        let moved = Self.task("Pay rent", day: yesterday, sortIndex: 1)
        let last = Self.task("Walk the dog", day: yesterday, sortIndex: 2)
        try Self.insert([first, moved, last], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(ids: [moved.id], toStartOf: try Self.day("2026-10-26"))
        let yesterdaysTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: yesterday)

        #expect(yesterdaysTasks == [first, last])
    }

    @Test func aTaskMovedToTheTopOfItsOwnDayLeavesItsOldPlace() async throws {
        let container = try Self.inMemoryContainer()
        let tomorrow = try Self.day("2026-10-26")
        let overdue = Self.task("Pay rent", day: try Self.day("2026-10-24"), sortIndex: 0)
        let tomorrows = Self.task("Walk the dog", day: tomorrow, sortIndex: 1)
        try Self.insert([overdue, Self.task("Buy milk", day: tomorrow, sortIndex: 0), tomorrows], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(ids: [overdue.id, tomorrows.id], toStartOf: tomorrow)
        let tomorrowsTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: tomorrow)

        #expect(tomorrowsTasks.map(\.name) == ["Pay rent", "Walk the dog", "Buy milk"])
        #expect(tomorrowsTasks.map(\.sortIndex) == [0, 1, 2])
    }

    @Test func movingTasksToTheTopOfADaySkipsIDsWithNoTask() async throws {
        let container = try Self.inMemoryContainer()
        let tomorrow = try Self.day("2026-10-26")
        let moved = Self.task("Pay rent", day: try Self.day("2026-10-24"), sortIndex: 0)
        try Self.insert([moved, Self.task("Buy milk", day: tomorrow, sortIndex: 3)], into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(ids: [UUID(), moved.id, UUID()], toStartOf: tomorrow)
        let tomorrowsTasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: tomorrow)

        #expect(tomorrowsTasks.map(\.name) == ["Pay rent", "Buy milk"])
    }

    @Test(.container) func tasksMovedToTheTopOfADayAreSavedOnce() async throws {
        let saves = Mutex(0)
        Container.shared.afterStoreSave.register { { saves.withLock { $0 += 1 } } }
        let container = try Self.inMemoryContainer()
        let yesterday = try Self.day("2026-10-24")
        let tasks = [
            Self.task("Pay rent", day: yesterday, sortIndex: 0),
            Self.task("Buy milk", day: yesterday, sortIndex: 1),
        ]
        try Self.insert(tasks, into: container)
        let repository = TodoTaskRepositoryLive(modelContainer: container)

        try await repository.move(ids: tasks.map(\.id), toStartOf: try Self.day("2026-10-26"))

        #expect(saves.withLock { $0 } == 1)
    }

    @Test(.container) func movingOnlyIDsWithNoTaskSavesNothing() async throws {
        let saves = Mutex(0)
        Container.shared.afterStoreSave.register { { saves.withLock { $0 += 1 } } }
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())

        try await repository.move(ids: [UUID()], toStartOf: try Self.day("2026-10-26"))

        #expect(saves.withLock { $0 } == 0)
    }

    @Test(.timeLimit(.minutes(1)))
    func scheduleTasksAreSentAgainAfterTasksAreMovedToTheTopOfADay() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let today = try Self.day("2026-10-25")
        let tomorrow = try Self.day("2026-10-26")
        try await repository.create(name: "Buy milk", day: today)
        try await repository.create(name: "Pay rent", day: today)
        var scheduleTasks = try await repository.scheduleTasks(today: today, historyFirstDay: nil).makeAsyncIterator()
        let tasks = try #require(await scheduleTasks.next())

        try await repository.move(ids: tasks.map(\.id).reversed(), toStartOf: tomorrow)

        let sent = try #require(await scheduleTasks.next())
        #expect(sent.map(\.name) == ["Pay rent", "Buy milk"])
        #expect(sent.map(\.day) == [tomorrow, tomorrow])
    }
}
