import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct TodoTaskRepositoryLiveTests {
    // MARK: - Tests
    @Test func aTaskRoundTripsEveryField() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let day = try Self.day("2026-10-25")
        let task = TodoTask(id: UUID(), name: "Buy milk", day: day, isComplete: true, sortIndex: 7)

        try await repository.create(task)

        #expect(try await repository.tasks(on: day) == [task])
    }

    @Test func aDayIsStoredAsGiven() async throws {
        let container = try Self.inMemoryContainer()
        let repository = TodoTaskRepositoryLive(modelContainer: container)
        let day = try Self.day("2026-10-25")

        try await repository.create(TodoTask(id: UUID(), name: "Buy milk", day: day, isComplete: false, sortIndex: 0))

        let stored = try ModelContext(container).fetch(FetchDescriptor<TodoTaskModel>())
        #expect(stored.map(\.day) == [day])
    }

    @Test func tasksOnADayComeBackOnlyForThatDay() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let days = try ["2026-10-24", "2026-10-25", "2026-10-26"].map(Self.day)
        let tasks = days.enumerated().flatMap { index, day in
            (0...index).map { TodoTask(id: UUID(), name: "Task \($0)", day: day, isComplete: false, sortIndex: $0) }
        }
        for task in tasks {
            try await repository.create(task)
        }

        let tasksOnDay = try await repository.tasks(on: days[1])

        #expect(Set(tasksOnDay.map(\.id)) == Set(tasks.filter { $0.day == days[1] }.map(\.id)))
        #expect(tasksOnDay.count == 2)
    }

    @Test func tasksFromTodayOnIncludeTodayAndLeaveOutYesterday() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        let later = try Self.day("2027-03-01")
        let tasks = [yesterday, today, later].map {
            TodoTask(id: UUID(), name: "Buy milk", day: $0, isComplete: false, sortIndex: 0)
        }
        for task in tasks {
            try await repository.create(task)
        }

        let tasksFromToday = try await repository.tasks(onOrAfter: today)

        #expect(Set(tasksFromToday.map(\.day)) == [today, later])
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
