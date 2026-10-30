import Domain
import Foundation
import Testing

struct ScheduleTests {
    // MARK: - Tests
    @Test func theWindowShowsEveryDayFromTodayThroughTodayPlus99EvenWhenEmpty() throws {
        let today = try day("2026-03-01")

        let schedule = Schedule(tasks: [], today: today)

        #expect(schedule.days.count == 100)
        #expect(schedule.days.first?.day == today)
        #expect(schedule.days.last?.day == (try day("2026-06-08")))
        #expect(schedule.days.allSatisfy { $0.tasks.isEmpty })
    }

    @Test func eachDayHoldsItsTasksOrderedBySortIndex() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Third", day: tomorrow, sortIndex: 7),
            task("First", day: tomorrow, sortIndex: 0),
            task("Today's", day: today, sortIndex: 0),
            task("Second", day: tomorrow, sortIndex: 3),
        ]

        let schedule = Schedule(tasks: tasks, today: today)

        #expect(schedule.days[0].tasks.map(\.name) == ["Today's"])
        #expect(schedule.days[1].tasks.map(\.name) == ["First", "Second", "Third"])
        #expect(schedule.days.dropFirst(2).allSatisfy { $0.tasks.isEmpty })
    }

    @Test func aDayAfterTheWindowAppearsOnlyWhenItHasTasks() throws {
        let today = try day("2026-03-01")
        let tasks = [
            task("Much later", day: try day("2026-09-01"), sortIndex: 0),
            task("Just after", day: try day("2026-06-09"), sortIndex: 1, completeDay: today),
            task("Also just after", day: try day("2026-06-09"), sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today)

        let laterDays = schedule.days.dropFirst(100)
        #expect(laterDays.map(\.day) == [try day("2026-06-09"), try day("2026-09-01")])
        #expect(laterDays.map { $0.tasks.map(\.name) } == [["Also just after", "Just after"], ["Much later"]])
    }

    @Test func aWindowThatCrossesAYearBoundaryRunsOnIntoTheNewYear() throws {
        let today = try day("2026-12-30")
        let newYearsDay = try day("2027-01-01")

        let schedule = Schedule(tasks: [task("Celebrate", day: newYearsDay, sortIndex: 0)], today: today)

        #expect(schedule.days.prefix(3).map(\.day) == [today, try day("2026-12-31"), newYearsDay])
        #expect(schedule.days[2].tasks.map(\.name) == ["Celebrate"])
        #expect(schedule.days.count == 100)
        #expect(schedule.days.last?.day == (try day("2027-04-08")))
    }

    @Test func overdueHoldsOnlyIncompleteTasksBeforeTodayByDayThenSortIndex() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let lastYear = try day("2025-12-31")
        let tasks = [
            task("Yesterday's second", day: yesterday, sortIndex: 4),
            task("Done yesterday", day: yesterday, sortIndex: 2, completeDay: yesterday),
            task("Yesterday's first", day: yesterday, sortIndex: 1),
            task("Last year's", day: lastYear, sortIndex: 9),
            task("Today's", day: today, sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today)

        #expect(schedule.overdue.map(\.name) == ["Last year's", "Yesterday's first", "Yesterday's second"])
        #expect(schedule.days.first?.tasks.map(\.name) == ["Today's"])
    }

    @Test func aTaskCompletedFromOverdueOnTodayStaysInOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let tasks = [
            task("Completed from Overdue", day: yesterday, sortIndex: 1, completeDay: today),
            task("Still to do", day: yesterday, sortIndex: 2),
        ]

        let schedule = Schedule(tasks: tasks, today: today)

        #expect(schedule.overdue.map(\.name) == ["Completed from Overdue", "Still to do"])
    }

    @Test func aTaskCompletedOnAnEarlierDayLeavesOverdue() throws {
        let today = try day("2026-03-01")
        let twoDaysAgo = try day("2026-02-27")
        let tasks = [
            task("Completed yesterday", day: twoDaysAgo, sortIndex: 0, completeDay: try day("2026-02-28")),
            task("Still to do", day: twoDaysAgo, sortIndex: 1),
        ]

        let schedule = Schedule(tasks: tasks, today: today)

        #expect(schedule.overdue.map(\.name) == ["Still to do"])
    }

    // MARK: - Helpers
    private func task(_ name: String, day: Date, sortIndex: Int, completeDay: Date? = nil) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeDay: completeDay, sortIndex: sortIndex)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
