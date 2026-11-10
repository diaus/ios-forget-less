import Domain
import Foundation
import Testing

struct ScheduleTests {
    // MARK: - Tests
    @Test func theWindowShowsEveryDayFromTodayThroughTodayPlus99EvenWhenEmpty() throws {
        let today = try day("2026-03-01")

        let schedule = Schedule(tasks: [], today: today, now: today)

        #expect(schedule.days.count == 100)
        #expect(schedule.days.first?.day == today)
        #expect(schedule.days.last?.day == (try day("2026-06-08")))
        #expect(schedule.days.allSatisfy { $0.tasks.isEmpty })
    }

    @Test func eachDayHoldsItsOwnTasks() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let tasks = [
            task("Today's", day: today, sortIndex: 0),
            task("First", day: tomorrow, sortIndex: 0),
            task("Second", day: tomorrow, sortIndex: 3),
            task("Third", day: tomorrow, sortIndex: 7),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: today)

        #expect(schedule.days[0].tasks.map(\.name) == ["Today's"])
        #expect(schedule.days[1].tasks.map(\.name) == ["First", "Second", "Third"])
        #expect(schedule.days.dropFirst(2).allSatisfy { $0.tasks.isEmpty })
    }

    @Test func aDayAfterTheWindowAppearsOnlyWhenItHasTasks() throws {
        let today = try day("2026-03-01")
        let tasks = [
            task("Also just after", day: try day("2026-06-09"), sortIndex: 0),
            task("Just after", day: try day("2026-06-09"), sortIndex: 1, completeTime: today),
            task("Much later", day: try day("2026-09-01"), sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: today)

        let laterDays = schedule.days.dropFirst(100)
        #expect(laterDays.map(\.day) == [try day("2026-06-09"), try day("2026-09-01")])
        #expect(laterDays.map { $0.tasks.map(\.name) } == [["Also just after", "Just after"], ["Much later"]])
    }

    @Test func aWindowThatCrossesAYearBoundaryRunsOnIntoTheNewYear() throws {
        let today = try day("2026-12-30")
        let newYearsDay = try day("2027-01-01")

        let schedule = Schedule(tasks: [task("Celebrate", day: newYearsDay, sortIndex: 0)], today: today, now: today)

        #expect(schedule.days.prefix(3).map(\.day) == [today, try day("2026-12-31"), newYearsDay])
        #expect(schedule.days[2].tasks.map(\.name) == ["Celebrate"])
        #expect(schedule.days.count == 100)
        #expect(schedule.days.last?.day == (try day("2027-04-08")))
    }

    @Test func overdueHoldsOnlyIncompleteTasksBeforeToday() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let lastYear = try day("2025-12-31")
        let tasks = [
            task("Last year's", day: lastYear, sortIndex: 9),
            task("Yesterday's first", day: yesterday, sortIndex: 1),
            task("Done yesterday", day: yesterday, sortIndex: 2, completeTime: yesterday),
            task("Yesterday's second", day: yesterday, sortIndex: 4),
            task("Today's", day: today, sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: today)

        #expect(schedule.overdue.map(\.name) == ["Last year's", "Yesterday's first", "Yesterday's second"])
        #expect(schedule.days.first?.tasks.map(\.name) == ["Today's"])
    }

    @Test func aTaskCompletedFromOverdueStaysThereForAnHour() throws {
        let yesterday = try day("2026-02-28")
        let now = try moment("2026-03-01T10:00:00Z")
        let tasks = [
            task("Completed 61 minutes ago", day: yesterday, sortIndex: 0, completeTime: minutes(61, before: now)),
            task("Completed 59 minutes ago", day: yesterday, sortIndex: 1, completeTime: minutes(59, before: now)),
            task("Still to do", day: yesterday, sortIndex: 2),
        ]

        let schedule = Schedule(tasks: tasks, today: try day("2026-03-01"), now: now)

        #expect(schedule.overdue.map(\.name) == ["Completed 59 minutes ago", "Still to do"])
    }

    @Test func aTaskCompletedFromOverdueBeforeMidnightStaysThereOnTheNextToday() throws {
        let completed = task(
            "Completed at 23:30", day: try day("2026-02-27"), sortIndex: 0,
            completeTime: try moment("2026-02-28T23:30:00Z")
        )

        let schedule = Schedule(
            tasks: [completed], today: try day("2026-03-01"), now: try moment("2026-03-01T00:15:00Z")
        )

        #expect(schedule.overdue.map(\.name) == ["Completed at 23:30"])
    }

    @Test func overdueIncompleteLeavesOutTasksCompletedFromOverdueAndKeepsTheOrder() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let lastWeek = try day("2026-02-22")
        let now = try moment("2026-03-01T10:00:00Z")
        let tasks = [
            task("Last week's second", day: lastWeek, sortIndex: 5),
            task("Completed from Overdue", day: lastWeek, sortIndex: 6, completeTime: now),
            task("Yesterday's first", day: yesterday, sortIndex: 0),
            task("Yesterday's second", day: yesterday, sortIndex: 2),
            task("Today's", day: today, sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: now)

        let names = schedule.overdueIncomplete.map(\.name)
        #expect(names == ["Last week's second", "Yesterday's first", "Yesterday's second"])
    }

    @Test func theNextOverdueHourEndIsWhenTheFirstTaskKeptInOverdueLeavesIt() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let now = try moment("2026-03-01T10:00:00Z")
        let tasks = [
            task("Completed 20 minutes ago", day: yesterday, sortIndex: 0, completeTime: minutes(20, before: now)),
            task("Completed 50 minutes ago", day: yesterday, sortIndex: 1, completeTime: minutes(50, before: now)),
            task("Completed two hours ago", day: yesterday, sortIndex: 2, completeTime: minutes(120, before: now)),
            task("Still to do", day: yesterday, sortIndex: 3),
            task("Completed on Today", day: today, sortIndex: 0, completeTime: minutes(55, before: now)),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: now)

        #expect(schedule.nextOverdueHourEnd == (try moment("2026-03-01T10:10:00Z")))
    }

    @Test func overdueKeepingNoCompleteTaskHasNoNextOverdueHourEnd() throws {
        let today = try day("2026-03-01")
        let now = try moment("2026-03-01T10:00:00Z")
        let tasks = [
            task("Still to do", day: try day("2026-02-28"), sortIndex: 0),
            task("Completed on Today", day: today, sortIndex: 0, completeTime: now),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: now)

        #expect(schedule.nextOverdueHourEnd == nil)
    }

    @Test func hidingCompleteTasksDropsThemFromEveryDayAndOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let now = try moment("2026-03-01T10:00:00Z")
        let tasks = [
            task("Completed from Overdue", day: yesterday, sortIndex: 0, completeTime: now),
            task("Overdue", day: yesterday, sortIndex: 1),
            task("Completed today", day: today, sortIndex: 0, completeTime: now),
            task("To do today", day: today, sortIndex: 1),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: now, showsComplete: false, keptTaskIDs: [])

        #expect(schedule.overdue.map(\.name) == ["Overdue"])
        #expect(schedule.days.first?.tasks.map(\.name) == ["To do today"])
    }

    @Test func aKeptTaskStaysWhileCompleteTasksAreHidden() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let now = try moment("2026-03-01T10:00:00Z")
        let keptFromOverdue = task("Just completed from Overdue", day: yesterday, sortIndex: 0, completeTime: now)
        let kept = task("Just completed", day: today, sortIndex: 0, completeTime: now)
        let tasks = [keptFromOverdue, kept, task("Completed earlier", day: today, sortIndex: 1, completeTime: now)]

        let schedule = Schedule(
            tasks: tasks, today: today, now: now, showsComplete: false, keptTaskIDs: [keptFromOverdue.id, kept.id]
        )

        #expect(schedule.overdue.map(\.name) == ["Just completed from Overdue"])
        #expect(schedule.days.first?.tasks.map(\.name) == ["Just completed"])
    }

    @Test func aKeptTaskCompletedFromOverdueStillLeavesItOnceItsHourEnds() throws {
        let now = try moment("2026-03-01T10:00:00Z")
        let kept = task(
            "Completed 61 minutes ago", day: try day("2026-02-28"), sortIndex: 0, completeTime: minutes(61, before: now)
        )

        let schedule = Schedule(
            tasks: [kept], today: try day("2026-03-01"), now: now, showsComplete: false, keptTaskIDs: [kept.id]
        )

        #expect(schedule.overdue.isEmpty)
    }

    @Test func aDayAfterTheWindowWithOnlyHiddenTasksIsNotListed() throws {
        let today = try day("2026-03-01")
        let tasks = [
            task("Completed ahead", day: try day("2026-07-01"), sortIndex: 0, completeTime: today),
            task("Still to do", day: try day("2026-09-01"), sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today, now: today, showsComplete: false, keptTaskIDs: [])

        #expect(schedule.days.dropFirst(100).map(\.day) == [try day("2026-09-01")])
    }

    @Test func aDayInTheWindowWithOnlyHiddenTasksStaysListedWithNoTasks() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")

        let schedule = Schedule(
            tasks: [task("Completed ahead", day: tomorrow, sortIndex: 0, completeTime: today)],
            today: today,
            now: today,
            showsComplete: false,
            keptTaskIDs: []
        )

        #expect(schedule.days[1].day == tomorrow)
        #expect(schedule.days[1].tasks.isEmpty)
    }

    // MARK: - Helpers
    func task(_ name: String, day: Date, sortIndex: Int, completeTime: Date? = nil) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeTime: completeTime, sortIndex: sortIndex)
    }

    /// The moment `yyyy-MM-ddTHH:mm:ssZ`.
    func moment(_ iso8601: String) throws -> Date {
        try Date(iso8601, strategy: .iso8601)
    }

    func minutes(_ count: Int, before moment: Date) -> Date {
        moment.addingTimeInterval(-Double(count) * 60)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
