import Domain
import Foundation
import Testing

/// The Schedule in History.
extension ScheduleTests {
    // MARK: - History
    @Test func historyListsEveryDayFromTheFirstDayThroughTheWindowEvenWhenEmptyThenLaterDaysWithTasks() throws {
        let today = try day("2026-03-01")
        let firstDay = try day("2026-02-26")
        let laterDay = try day("2026-09-01")
        let tasks = [
            task("Two days ago", day: try day("2026-02-27"), sortIndex: 0),
            task("Renew passport", day: laterDay, sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today, historyFirstDay: firstDay)

        let pastDays = try ["2026-02-26", "2026-02-27", "2026-02-28"].map(day)
        #expect(schedule.days.prefix(4).map(\.day) == pastDays + [today])
        #expect(schedule.days.prefix(3).map { $0.tasks.map(\.name) } == [[], ["Two days ago"], []])
        #expect(schedule.days.count == 3 + 100 + 1)
        #expect(schedule.days[3 + 99].day == (try day("2026-06-08")))
        #expect(schedule.days.last?.day == laterDay)
    }

    @Test func historyListsTasksCompletedFromOverdueOnTheirDaysAndHasNoOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let tasks = [
            task("Completed yesterday", day: yesterday, sortIndex: 0, completeDay: yesterday),
            task("Overdue", day: yesterday, sortIndex: 1),
            task("Completed from Overdue", day: yesterday, sortIndex: 2, completeDay: today),
            task("Completed today", day: today, sortIndex: 0, completeDay: today),
        ]

        let schedule = Schedule(tasks: tasks, today: today, historyFirstDay: yesterday)

        #expect(schedule.overdue.isEmpty)
        #expect(schedule.days[0].tasks.map(\.name) == ["Completed yesterday", "Overdue", "Completed from Overdue"])
        #expect(schedule.days[1].tasks.map(\.name) == ["Completed today"])
    }

    @Test(.firstWeekday(2))
    func historysWeeksAndMonthsCarryOnAcrossThePastAndIntoToday() throws {
        // Monday 2026-11-02, with weeks starting on Monday.
        let today = try day("2026-11-02")
        let firstDay = try day("2026-10-20")

        let schedule = Schedule(tasks: [], today: today, historyFirstDay: firstDay)

        let throughToday = schedule.days.prefix { $0.day <= today }
        #expect(throughToday.filter(\.startsWeek).map(\.day) == [try day("2026-10-26"), today])
        #expect(throughToday.filter(\.startsMonth).map(\.day) == [try day("2026-11-01")])
    }

    // MARK: - Paging History
    @Test(arguments: ["2026-02-20", "2026-02-21", "2026-12-25"])
    func aDayHistoryListsAlreadyKeepsItsFirstDay(listedDay: String) throws {
        let historyFirstDay = try day("2026-02-20")

        #expect(Schedule.historyFirstDay(listing: try day(listedDay), from: historyFirstDay) == historyFirstDay)
    }

    @Test(arguments: ["2026-02-19", "2025-08-10"])
    func aDayBeforeTheHistoryFirstDayMovesItAPageBeforeThatDay(earlierDay: String) throws {
        let earlierDay = try day(earlierDay)

        let historyFirstDay = Schedule.historyFirstDay(listing: earlierDay, from: try day("2026-02-20"))

        #expect(historyFirstDay == earlierDay.addingDays(-Schedule.historyPageDayCount))
    }

    // MARK: - Going to a Day
    @Test(arguments: ["2026-02-27", "2026-03-01", "2026-03-02", "2026-06-08", "2026-09-01"])
    func aListedDayIsTheListedDayOnOrBeforeItself(listedDay: String) throws {
        let today = try day("2026-03-01")
        let laterDay = try day("2026-09-01")
        let tasks = [task("Renew passport", day: laterDay, sortIndex: 0)]
        let schedule = Schedule(tasks: tasks, today: today, historyFirstDay: try day("2026-02-20"))

        #expect(schedule.listedDay(onOrBefore: try day(listedDay)) == (try day(listedDay)))
    }

    @Test func anEmptyDayAfterTheWindowGivesTheClosestLaterDayWithTasksBeforeIt() throws {
        let today = try day("2026-03-01")
        let laterDay = try day("2026-09-01")
        let tasks = [task("Renew passport", day: laterDay, sortIndex: 0)]
        let schedule = Schedule(tasks: tasks, today: today, historyFirstDay: try day("2026-02-20"))

        #expect(schedule.listedDay(onOrBefore: try day("2026-12-25")) == laterDay)
    }

    @Test func anEmptyDayAfterTheWindowWithNoLaterDayBeforeItGivesTheWindowsLastDay() throws {
        let today = try day("2026-03-01")
        let laterDay = try day("2026-09-01")
        let tasks = [task("Renew passport", day: laterDay, sortIndex: 0)]
        let schedule = Schedule(tasks: tasks, today: today, historyFirstDay: try day("2026-02-20"))

        #expect(schedule.listedDay(onOrBefore: try day("2026-07-04")) == (try day("2026-06-08")))
    }

    @Test func aDayBeforeTheFirstListedDayGivesNone() throws {
        let schedule = Schedule(tasks: [], today: try day("2026-03-01"), historyFirstDay: try day("2026-02-20"))

        #expect(schedule.listedDay(onOrBefore: try day("2026-02-19")) == nil)
    }

    // MARK: - Moving in History
    @Test func inHistoryATaskCanMoveDropOrMoveToTheEndOntoAPastDay() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let firstDay = try day("2026-02-20")
        let yesterdays = task("Buy milk", day: yesterday, sortIndex: 0, completeDay: yesterday)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [yesterdays, todays], today: today, historyFirstDay: firstDay)

        #expect(schedule.canMove(todays, to: MoveDestination(day: yesterday, after: yesterdays.id)))
        #expect(schedule.canMove(todays, to: MoveDestination(day: firstDay, after: nil)))
        #expect(schedule.canMove(todays, droppedOn: yesterday, at: 1))
        #expect(schedule.canMoveToEnd(todays, of: yesterday))
        // A Day before the first one listed can still be chosen in a Day picker.
        #expect(schedule.canMoveToEnd(todays, of: try day("2025-06-01")))
    }

    @Test func inHistoryMoveUpFromTodaysFirstTaskGoesToTheEndOfYesterday() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let yesterdays = task("Buy milk", day: yesterday, sortIndex: 0)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [yesterdays, todays], today: today, historyFirstDay: try day("2026-02-20"))

        #expect(schedule.destinationOneStepUp(for: todays) == MoveDestination(day: yesterday, after: yesterdays.id))
        #expect(schedule.destinationOneStepDown(for: yesterdays) == MoveDestination(day: today, after: nil))
    }

    @Test func outsideHistoryAMoveDropOrMoveToTheEndOntoAPastDayIsRefused() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let overdue = task("Buy milk", day: yesterday, sortIndex: 0)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [overdue, todays], today: today)

        #expect(!schedule.canMove(todays, to: MoveDestination(day: yesterday, after: overdue.id)))
        #expect(!schedule.canMove(todays, droppedOn: yesterday, at: 0))
        #expect(!schedule.canMoveToEnd(todays, of: yesterday))
        #expect(schedule.destinationOneStepUp(for: todays) == nil)
    }
}
