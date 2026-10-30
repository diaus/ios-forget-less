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
            task("Just after", day: try day("2026-06-09"), sortIndex: 1, isComplete: true),
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

    // MARK: - Helpers
    private func task(_ name: String, day: Date, sortIndex: Int, isComplete: Bool = false) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, isComplete: isComplete, sortIndex: sortIndex)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
