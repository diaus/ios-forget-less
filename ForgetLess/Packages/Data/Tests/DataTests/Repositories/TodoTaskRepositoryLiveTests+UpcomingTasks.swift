import Domain
import Foundation
import Testing
@testable import Data

/// The Tasks the widget lists between two Days: the Incomplete ones, and the Complete ones in its Grace Period.
extension TodoTaskRepositoryLiveTests {
    @Test func upcomingTasksWithNoFirstDayHoldEveryIncompleteTaskThroughTheLastDay() async throws {
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

        let upcoming = try await TodoTaskRepositoryLive(modelContainer: container)
            .upcomingTasks(from: nil, through: today, completedWithin: 0, before: today)

        #expect(upcoming.map(\.name) == ["Last year's", "Yesterday's", "Today's"])
    }

    @Test func upcomingTasksFromTodayLeaveOutOverdueTasks() async throws {
        let container = try Self.inMemoryContainer()
        let today = try Self.day("2026-10-25")
        try Self.insert(
            [
                Self.task("Yesterday's", day: try Self.day("2026-10-24"), sortIndex: 0),
                Self.task("Today's", day: today, sortIndex: 0),
            ],
            into: container
        )

        let upcoming = try await TodoTaskRepositoryLive(modelContainer: container)
            .upcomingTasks(from: today, through: today, completedWithin: 0, before: today)

        #expect(upcoming.map(\.name) == ["Today's"])
    }

    @Test(arguments: [
        ("2026-10-25", ["Today's"]),
        ("2026-10-26", ["Today's", "Tomorrow's"]),
    ])
    func upcomingTasksHoldTomorrowsTasksOnlyThroughTomorrow(lastDay: String, names: [String]) async throws {
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

        let upcoming = try await TodoTaskRepositoryLive(modelContainer: container)
            .upcomingTasks(from: today, through: try Self.day(lastDay), completedWithin: 0, before: today)

        #expect(upcoming.map(\.name) == names)
    }

    @Test func upcomingTasksHoldATaskCompletedWithinTheGracePeriodButNotOneCompletedBefore() async throws {
        let container = try Self.inMemoryContainer()
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        let now = today.addingTimeInterval(9 * 60 * 60)
        try Self.insert(
            [
                Self.task("Overdue", day: yesterday, sortIndex: 0),
                Self.task("Kept in Overdue", day: yesterday, sortIndex: 1, completeTime: now - 2),
                Self.task("Completed earlier", day: today, sortIndex: 0, completeTime: now - 4),
                Self.task("Kept on Today", day: today, sortIndex: 1, completeTime: now - 1),
                Self.task("Today's", day: today, sortIndex: 2),
                Self.task("Kept on Tomorrow", day: today.addingDays(1), sortIndex: 0, completeTime: now - 1),
            ],
            into: container
        )

        let upcoming = try await TodoTaskRepositoryLive(modelContainer: container)
            .upcomingTasks(from: nil, through: today, completedWithin: 3, before: now)

        #expect(upcoming.map(\.name) == ["Overdue", "Kept in Overdue", "Kept on Today", "Today's"])
    }

    @Test func upcomingTasksWithNoGracePeriodHoldNoCompleteTaskEvenOneKeptInOverdue() async throws {
        let container = try Self.inMemoryContainer()
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        let now = today.addingTimeInterval(9 * 60 * 60)
        try Self.insert(
            [
                Self.task("Overdue", day: yesterday, sortIndex: 0),
                Self.task("Completed from Overdue", day: yesterday, sortIndex: 1, completeTime: now),
                Self.task("Today's", day: today, sortIndex: 0),
                Self.task("Completed today", day: today, sortIndex: 1, completeTime: now),
            ],
            into: container
        )

        let upcoming = try await TodoTaskRepositoryLive(modelContainer: container)
            .upcomingTasks(from: nil, through: today, completedWithin: 0, before: now)

        #expect(upcoming.map(\.name) == ["Overdue", "Today's"])
    }

    @Test func upcomingTasksComeBackByDayThenPosition() async throws {
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

        let upcoming = try await TodoTaskRepositoryLive(modelContainer: container)
            .upcomingTasks(from: nil, through: tomorrow, completedWithin: 0, before: today)

        #expect(upcoming.map(\.name) == [
            "Yesterday's first", "Yesterday's second", "Today's first", "Today's second", "Tomorrow's",
        ])
    }
}
