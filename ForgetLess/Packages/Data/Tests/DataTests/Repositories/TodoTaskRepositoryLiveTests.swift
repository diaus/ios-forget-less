import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct TodoTaskRepositoryLiveTests {
    // MARK: - Tests
    @Test func aTaskRoundTripsEveryField() async throws {
        let calendar = Self.calendar(secondsFromGMT: 2 * 3600)
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer(), calendar: calendar)
        let day = try Date("2026-10-25T00:00:00+02:00", strategy: .iso8601)
        let task = TodoTask(id: UUID(), name: "Buy milk", day: day, isComplete: true, sortIndex: 7)

        try await repository.create(task)

        #expect(try await repository.tasks(on: day) == [task])
    }

    @Test(arguments: [
        (-4 * 3600, "2026-10-25T00:00:00-04:00"),
        (2 * 3600, "2026-10-25T00:00:00+02:00"),
    ])
    func aDayIsStoredAsUTCMidnightAndReadsBackAsLocalMidnight(secondsFromGMT: Int, localMidnight: String) async throws {
        let container = try Self.inMemoryContainer()
        let calendar = Self.calendar(secondsFromGMT: secondsFromGMT)
        let repository = TodoTaskRepositoryLive(modelContainer: container, calendar: calendar)
        let day = try Date(localMidnight, strategy: .iso8601)

        try await repository.create(TodoTask(id: UUID(), name: "Buy milk", day: day, isComplete: false, sortIndex: 0))

        let stored = try ModelContext(container).fetch(FetchDescriptor<TodoTaskModel>())
        #expect(stored.map(\.day) == [try Date("2026-10-25T00:00:00Z", strategy: .iso8601)])
        #expect(try await repository.tasks(on: day).map(\.day) == [day])
    }

    @Test func tasksOnADayComeBackOnlyForThatDay() async throws {
        let calendar = Self.calendar(secondsFromGMT: -4 * 3600)
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer(), calendar: calendar)
        let days = try ["2026-10-24", "2026-10-25", "2026-10-26"].map {
            try Date("\($0)T00:00:00-04:00", strategy: .iso8601)
        }
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

    @Test(arguments: [-4 * 3600, 2 * 3600])
    func tasksFromTodayOnIncludeTodayAndLeaveOutYesterday(secondsFromGMT: Int) async throws {
        let calendar = Self.calendar(secondsFromGMT: secondsFromGMT)
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer(), calendar: calendar)
        let offset = String(format: "%+03d:00", secondsFromGMT / 3600)
        let yesterday = try Date("2026-10-24T00:00:00\(offset)", strategy: .iso8601)
        let today = try Date("2026-10-25T00:00:00\(offset)", strategy: .iso8601)
        let later = try Date("2027-03-01T00:00:00\(offset)", strategy: .iso8601)
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

    private static func calendar(secondsFromGMT: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: secondsFromGMT)!
        return calendar
    }
}
