import Domain
import Foundation
import Testing
@testable import Data

/// The Tasks the Schedule lists in History, from a first Day on.
extension TodoTaskRepositoryLiveTests {
    @Test func historysScheduleTasksHoldEveryTaskFromTheFirstDayOnByDayThenPosition() async throws {
        let container = try Self.inMemoryContainer()
        let firstDay = try Self.day("2026-10-20")
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        try Self.insert(
            [
                Self.task("Today's", day: today, sortIndex: 0),
                Self.task("Yesterday's second", day: yesterday, sortIndex: 1),
                Self.task("Completed on the first Day", day: firstDay, sortIndex: 0, completeTime: firstDay),
                Self.task("Before the first Day", day: try Self.day("2026-10-19"), sortIndex: 0),
                Self.task("Yesterday's first", day: yesterday, sortIndex: 0, completeTime: yesterday),
                Self.task("Later", day: try Self.day("2027-03-01"), sortIndex: 0, completeTime: today),
            ],
            into: container
        )

        let repository = TodoTaskRepositoryLive(modelContainer: container)
        var scheduleTasks = try await repository.scheduleTasks(today: today, historyFirstDay: firstDay)
            .makeAsyncIterator()

        let first = try #require(await scheduleTasks.next())
        #expect(first.map(\.name) == [
            "Completed on the first Day", "Yesterday's first", "Yesterday's second", "Today's", "Later",
        ])
    }

    @Test(.timeLimit(.minutes(1)))
    func historysScheduleTasksAreSentAgainAfterAWrite() async throws {
        let repository = TodoTaskRepositoryLive(modelContainer: try Self.inMemoryContainer())
        let yesterday = try Self.day("2026-10-24")
        let today = try Self.day("2026-10-25")
        var scheduleTasks = try await repository.scheduleTasks(today: today, historyFirstDay: yesterday)
            .makeAsyncIterator()
        #expect(await scheduleTasks.next() == [])

        try await repository.create(name: "Buy milk", day: yesterday)
        let created = try #require(await scheduleTasks.next()?.first)
        try await repository.setComplete(id: created.id, isComplete: true, now: today)
        let completed = try #require(await scheduleTasks.next()?.first)

        #expect(created.name == "Buy milk")
        #expect(created.day == yesterday)
        #expect(completed.completeTime == today)
    }
}
