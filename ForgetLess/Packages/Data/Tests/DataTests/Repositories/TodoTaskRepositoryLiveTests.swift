import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct TodoTaskRepositoryLiveTests {
    // MARK: - Tests
    @Test func aCreatedTaskIsIncompleteAndComesBackOnItsDay() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let day = try Self.day("2026-10-25")

        try await repository.create(name: "Buy milk", day: day)

        let tasks = try await repository.tasks(on: day)
        let task = try #require(tasks.first)
        #expect(tasks.count == 1)
        #expect(task.name == "Buy milk")
        #expect(task.day == day)
        #expect(!task.isComplete)
        #expect(task.sortIndex == 0)
    }

    @Test func aCreatedTaskGoesAtTheEndOfItsDayOnly() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let day = try Self.day("2026-10-25")
        let nextDay = try Self.day("2026-10-26")
        for _ in 0..<3 {
            try await repository.create(name: "Call mum", day: nextDay)
        }
        try await repository.create(name: "Buy milk", day: day)

        try await repository.create(name: "Walk the dog", day: day)

        let tasksOnDay = try await repository.tasks(on: day)
        #expect(tasksOnDay.first { $0.name == "Walk the dog" }?.sortIndex == 1)
    }

    @Test func aDayIsStoredAsGiven() async throws {
        let container = try Self.inMemoryContainer()
        let repository = TodoTaskRepositoryLive(modelContainer: container)
        let day = try Self.day("2026-10-25")

        try await repository.create(name: "Buy milk", day: day)

        let stored = try ModelContext(container).fetch(FetchDescriptor<TodoTaskModel>())
        #expect(stored.map(\.day) == [day])
    }

    @Test func tasksOnADayComeBackOnlyForThatDay() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let days = try ["2026-10-24", "2026-10-25", "2026-10-26"].map(Self.day)
        for (index, day) in days.enumerated() {
            for taskNumber in 0...index {
                try await repository.create(name: "Task \(taskNumber)", day: day)
            }
        }

        let tasksOnDay = try await repository.tasks(on: days[1])

        #expect(tasksOnDay.map(\.day) == [days[1], days[1]])
    }

    @Test func scheduleTasksHoldTodayOnIncompleteBeforeTodayAndThoseCompletedOnToday() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let lastYear = try Self.day("2025-12-31")
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        let later = try Self.day("2027-03-01")
        try await repository.create(name: "Overdue", day: lastYear)
        try await repository.create(name: "Completed today", day: yesterday)
        try await repository.create(name: "Completed yesterday", day: yesterday)
        try await repository.create(name: "Today's", day: today)
        try await repository.create(name: "Later", day: later)
        let yesterdays = try await repository.tasks(on: yesterday)
        let completedToday = try #require(yesterdays.first { $0.name == "Completed today" })
        let completedYesterday = try #require(yesterdays.first { $0.name == "Completed yesterday" })
        try await repository.setComplete(id: completedToday.id, isComplete: true, today: today)
        try await repository.setComplete(id: completedYesterday.id, isComplete: true, today: yesterday)

        var scheduleTasks = try await repository.scheduleTasks(today: today).makeAsyncIterator()

        let first = try #require(await scheduleTasks.next())
        #expect(Set(first.map(\.name)) == ["Overdue", "Completed today", "Today's", "Later"])
    }

    @Test(.timeLimit(.minutes(1)))
    func scheduleTasksAreSentAgainAfterEveryWrite() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let today = try Self.day("2026-10-25")
        var scheduleTasks = try await repository.scheduleTasks(today: today).makeAsyncIterator()
        #expect(await scheduleTasks.next() == [])

        try await repository.create(name: "Cal mum", day: today)
        let created = try #require(await scheduleTasks.next()?.first)
        try await repository.rename(id: created.id, name: "Call mum")
        let renamed = try #require(await scheduleTasks.next()?.first)
        try await repository.setComplete(id: created.id, isComplete: true, today: today)
        let completed = try #require(await scheduleTasks.next()?.first)

        #expect(created.name == "Cal mum")
        #expect(renamed.name == "Call mum")
        #expect(completed.completeDay == today)
    }

    @Test func settingATaskCompleteAndBackToIncompleteIsPersisted() async throws {
        let container = try Self.inMemoryContainer()
        let repository = TodoTaskRepositoryLive(modelContainer: container)
        let day = try Self.day("2026-10-25")
        try await repository.create(name: "Buy milk", day: day)
        try await repository.create(name: "Call mum", day: day)
        let created = try await repository.tasks(on: day)
        let task = try #require(created.first { $0.name == "Buy milk" })
        let other = try #require(created.first { $0.name == "Call mum" })

        let today = try Self.day("2026-10-27")

        try await repository.setComplete(id: task.id, isComplete: true, today: today)
        // A fresh repository on the same store, as after a relaunch.
        let completed = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)
        try await repository.setComplete(id: task.id, isComplete: false, today: today)
        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)

        var completeTask = task
        completeTask.completeDay = today
        #expect(Set(completed.map(\.id)) == [task.id, other.id])
        #expect(completed.first { $0.id == task.id } == completeTask)
        #expect(completed.first { $0.id == other.id } == other)
        #expect(incomplete.first { $0.id == task.id } == task)
    }

    @Test func aRenameIsPersistedAndLeavesTheTasksOtherFieldsAsTheyWere() async throws {
        let container = try Self.inMemoryContainer()
        let repository = TodoTaskRepositoryLive(modelContainer: container)
        let day = try Self.day("2026-10-25")
        try await repository.create(name: "Buy milk", day: day)
        try await repository.create(name: "Cal mum", day: day)
        let created = try await repository.tasks(on: day)
        let task = try #require(created.first { $0.name == "Cal mum" })
        let other = try #require(created.first { $0.name == "Buy milk" })
        try await repository.setComplete(id: task.id, isComplete: true, today: day)

        try await repository.rename(id: task.id, name: "Call mum")
        // A fresh repository on the same store, as after a relaunch.
        let renamed = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)

        let expected = TodoTask(id: task.id, name: "Call mum", day: day, completeDay: day, sortIndex: 1)
        #expect(Set(renamed.map(\.id)) == [task.id, other.id])
        #expect(renamed.first { $0.id == task.id } == expected)
        #expect(renamed.first { $0.id == other.id } == other)
    }

    @Test func aDeleteRemovesOnlyThatTaskAndTheRestOfItsDayKeepTheirOrder() async throws {
        let container = try Self.inMemoryContainer()
        let repository = TodoTaskRepositoryLive(modelContainer: container)
        let day = try Self.day("2026-10-25")
        let nextDay = try Self.day("2026-10-26")
        for name in ["Buy milk", "Call mum", "Walk the dog"] {
            try await repository.create(name: name, day: day)
        }
        try await repository.create(name: "Pay rent", day: nextDay)
        let created = try await repository.tasks(on: day)
        let task = try #require(created.first { $0.name == "Call mum" })
        let others = created.filter { $0.id != task.id }.sorted { $0.sortIndex < $1.sortIndex }

        try await repository.delete(id: task.id)
        // A fresh repository on the same store, as after a relaunch.
        let relaunched = TodoTaskRepositoryLive(modelContainer: container)
        let remaining = try await relaunched.tasks(on: day).sorted { $0.sortIndex < $1.sortIndex }
        let remainingOnNextDay = try await relaunched.tasks(on: nextDay)

        #expect(remaining.map(\.name) == ["Buy milk", "Walk the dog"])
        #expect(remaining == others)
        #expect(remainingOnNextDay.map(\.name) == ["Pay rent"])
    }

    @Test(.timeLimit(.minutes(1)))
    func scheduleTasksAreSentAgainAfterADelete() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let today = try Self.day("2026-10-25")
        try await repository.create(name: "Buy milk", day: today)
        var scheduleTasks = try await repository.scheduleTasks(today: today).makeAsyncIterator()
        let task = try #require(await scheduleTasks.next()?.first)

        try await repository.delete(id: task.id)

        #expect(await scheduleTasks.next() == [])
    }

    // MARK: - Helpers
    private static func inMemoryContainer() throws -> ModelContainer {
        try ForgetLessModelContainer.make(inMemory: true)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private static func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
