import Domain
import Foundation
import Testing
@testable import Data

/// The Incomplete Tasks the widget lists, between two Days.
extension TodoTaskRepositoryLiveTests {
    @Test func incompleteTasksWithNoFirstDayHoldEveryIncompleteTaskThroughTheLastDay() async throws {
        let container = try Self.inMemoryContainer()
        let today = try Self.day("2026-10-25")
        try Self.insert(
            [
                Self.task("Last year's", day: try Self.day("2025-12-31"), sortIndex: 0),
                Self.task("Yesterday's", day: try Self.day("2026-10-24"), sortIndex: 0),
                Self.task("Today's", day: today, sortIndex: 0),
                Self.task("Tomorrow's", day: try Self.day("2026-10-26"), sortIndex: 0),
            ],
            into: container
        )

        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container)
            .incompleteTasks(from: nil, through: today)

        #expect(incomplete.map(\.name) == ["Last year's", "Yesterday's", "Today's"])
    }

    @Test func incompleteTasksFromTodayLeaveOutOverdueTasks() async throws {
        let container = try Self.inMemoryContainer()
        let today = try Self.day("2026-10-25")
        try Self.insert(
            [
                Self.task("Yesterday's", day: try Self.day("2026-10-24"), sortIndex: 0),
                Self.task("Today's", day: today, sortIndex: 0),
            ],
            into: container
        )

        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container)
            .incompleteTasks(from: today, through: today)

        #expect(incomplete.map(\.name) == ["Today's"])
    }

    @Test(arguments: [
        ("2026-10-25", ["Today's"]),
        ("2026-10-26", ["Today's", "Tomorrow's"]),
    ])
    func incompleteTasksHoldTomorrowsTasksOnlyThroughTomorrow(lastDay: String, names: [String]) async throws {
        let container = try Self.inMemoryContainer()
        let today = try Self.day("2026-10-25")
        try Self.insert(
            [
                Self.task("Today's", day: today, sortIndex: 0),
                Self.task("Tomorrow's", day: try Self.day("2026-10-26"), sortIndex: 0),
                Self.task("Later", day: try Self.day("2026-10-27"), sortIndex: 0),
            ],
            into: container
        )

        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container)
            .incompleteTasks(from: today, through: try Self.day(lastDay))

        #expect(incomplete.map(\.name) == names)
    }

    @Test func incompleteTasksNeverHoldACompleteTaskEvenOneCompletedFromOverdueOnToday() async throws {
        let container = try Self.inMemoryContainer()
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        try Self.insert(
            [
                Self.task("Overdue", day: yesterday, sortIndex: 0),
                TodoTask(id: UUID(), name: "Completed from Overdue", day: yesterday, completeDay: today, sortIndex: 1),
                Self.task("Today's", day: today, sortIndex: 0),
                TodoTask(id: UUID(), name: "Completed today", day: today, completeDay: today, sortIndex: 1),
            ],
            into: container
        )

        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container)
            .incompleteTasks(from: nil, through: today)

        #expect(incomplete.map(\.name) == ["Overdue", "Today's"])
    }

    @Test func incompleteTasksComeBackByDayThenPosition() async throws {
        let container = try Self.inMemoryContainer()
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        let tomorrow = try Self.day("2026-10-26")
        try Self.insert(
            [
                Self.task("Tomorrow's", day: tomorrow, sortIndex: 0),
                Self.task("Today's second", day: today, sortIndex: 1),
                Self.task("Yesterday's second", day: yesterday, sortIndex: 1),
                Self.task("Today's first", day: today, sortIndex: 0),
                Self.task("Yesterday's first", day: yesterday, sortIndex: 0),
            ],
            into: container
        )

        let incomplete = try await TodoTaskRepositoryLive(modelContainer: container)
            .incompleteTasks(from: nil, through: tomorrow)

        #expect(incomplete.map(\.name) == [
            "Yesterday's first", "Yesterday's second", "Today's first", "Today's second", "Tomorrow's",
        ])
    }
}
