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

    @Test func tasksFromTodayOnIncludeTodayAndLeaveOutYesterday() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        let later = try Self.day("2027-03-01")
        for day in [yesterday, today, later] {
            try await repository.create(name: "Buy milk", day: day)
        }

        let tasksFromToday = try await repository.tasks(onOrAfter: today)

        #expect(Set(tasksFromToday.map(\.day)) == [today, later])
    }

    @Test func incompleteTasksBeforeTodayLeaveOutTodayAndCompleteTasks() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let lastYear = try Self.day("2025-12-31")
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        for day in [lastYear, yesterday, today] {
            try await repository.create(name: "Buy milk", day: day)
        }
        try await repository.create(name: "Call mum", day: yesterday)
        let completed = try #require(try await repository.tasks(on: yesterday).first { $0.name == "Call mum" })
        try await repository.setComplete(id: completed.id, isComplete: true)

        let overdue = try await repository.incompleteTasks(before: today)

        #expect(Set(overdue.map(\.day)) == [lastYear, yesterday])
        #expect(overdue.map(\.name) == ["Buy milk", "Buy milk"])
    }

    @Test func tasksByIdComeBackOnlyForThoseIds() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        try await repository.create(name: "Buy milk", day: yesterday)
        try await repository.create(name: "Call mum", day: yesterday)
        try await repository.create(name: "Walk the dog", day: today)
        let created = try await repository.tasks(onOrAfter: yesterday)
        let wanted = created.filter { $0.name != "Call mum" }

        let found = try await repository.tasks(ids: Set(wanted.map(\.id) + [UUID()]))

        #expect(Set(found.map(\.id)) == Set(wanted.map(\.id)))
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

        try await repository.setComplete(id: task.id, isComplete: true)
        // A fresh repository on the same store, as after a relaunch.
        let completed = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)
        try await repository.setComplete(id: task.id, isComplete: false)
        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)

        var completeTask = task
        completeTask.isComplete = true
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
        try await repository.setComplete(id: task.id, isComplete: true)

        try await repository.rename(id: task.id, name: "Call mum")
        // A fresh repository on the same store, as after a relaunch.
        let renamed = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)

        let expected = TodoTask(id: task.id, name: "Call mum", day: day, isComplete: true, sortIndex: 1)
        #expect(Set(renamed.map(\.id)) == [task.id, other.id])
        #expect(renamed.first { $0.id == task.id } == expected)
        #expect(renamed.first { $0.id == other.id } == other)
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
