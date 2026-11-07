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

    @Test func historyListsCompleteTasksOnTheirDaysEvenWhileHiddenAndHasNoOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let tasks = [
            task("Completed yesterday", day: yesterday, sortIndex: 0, completeDay: yesterday),
            task("Overdue", day: yesterday, sortIndex: 1),
            task("Completed from Overdue", day: yesterday, sortIndex: 2, completeDay: today),
            task("Completed today", day: today, sortIndex: 0, completeDay: today),
        ]

        let schedule = Schedule(
            tasks: tasks, today: today, showsComplete: false, keptTaskIDs: [], historyFirstDay: yesterday
        )

        #expect(schedule.overdue.isEmpty)
        #expect(schedule.days[0].tasks.map(\.name) == ["Completed yesterday", "Overdue", "Completed from Overdue"])
        #expect(schedule.days[1].tasks.map(\.name) == ["Completed today"])
    }

    @Test func historysWeeksAndMonthsCarryOnAcrossThePastAndIntoToday() throws {
        // Monday 2026-11-02, with weeks starting on Monday.
        let today = try day("2026-11-02")
        let firstDay = try day("2026-10-20")

        let schedule = Schedule(tasks: [], today: today, firstWeekday: 2, historyFirstDay: firstDay)

        let throughToday = schedule.days.prefix { $0.day <= today }
        #expect(throughToday.filter(\.startsWeek).map(\.day) == [try day("2026-10-26"), today])
        #expect(throughToday.filter(\.startsMonth).map(\.day) == [try day("2026-11-01")])
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
