import Domain
import Foundation
import Testing

struct LoadScheduleTests {
    private let today = Date(timeIntervalSinceReferenceDate: 86_400)
    private let yesterday = Date(timeIntervalSinceReferenceDate: 0)

    // MARK: - Tests
    @Test func loadScheduleListsTasksFromTodayOnTheOverdueTasksAndTheKeptOnes() async throws {
        let repository = FakeTodoTaskRepository()
        await repository.create(name: "Today's", day: today)
        await repository.create(name: "Overdue", day: yesterday)
        await repository.create(name: "Kept", day: yesterday)
        await repository.create(name: "Completed earlier", day: yesterday)
        let kept = try await task(named: "Kept", in: repository)
        try await complete(["Kept", "Completed earlier"], in: repository)

        let schedule = try await LoadSchedule(repository: repository)(today: today, keepingOverdue: [kept.id])

        #expect(schedule.overdue.map(\.name) == ["Overdue", "Kept"])
        #expect(schedule.days.first?.tasks.map(\.name) == ["Today's"])
    }

    @Test func aKeptTaskMadeIncompleteAgainIsListedOnce() async throws {
        let repository = FakeTodoTaskRepository()
        await repository.create(name: "Kept", day: yesterday)
        let kept = try await task(named: "Kept", in: repository)

        let schedule = try await LoadSchedule(repository: repository)(today: today, keepingOverdue: [kept.id])

        #expect(schedule.overdue.map(\.id) == [kept.id])
    }

    // MARK: - Helpers
    private func task(named name: String, in repository: FakeTodoTaskRepository) async throws -> TodoTask {
        try #require(await repository.tasks.first { $0.name == name })
    }

    private func complete(_ names: [String], in repository: FakeTodoTaskRepository) async throws {
        for name in names {
            try await repository.setComplete(id: task(named: name, in: repository).id, isComplete: true)
        }
    }
}
