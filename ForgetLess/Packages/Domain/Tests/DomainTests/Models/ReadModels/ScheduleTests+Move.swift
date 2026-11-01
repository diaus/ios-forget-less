import Domain
import Foundation
import Testing

/// The move rule, and the steps VoiceOver users Move a Task by.
extension ScheduleTests {
    // MARK: - Move Rule
    @Test func anOverdueTaskCantMoveWithinOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let first = task("Buy milk", day: yesterday, sortIndex: 0)
        let second = task("Call mum", day: yesterday, sortIndex: 1)
        let schedule = Schedule(tasks: [first, second], today: today)

        #expect(!schedule.canMove(second, to: MoveDestination(day: yesterday, after: nil)))
        #expect(!schedule.canMove(first, to: MoveDestination(day: yesterday, after: second.id)))
    }

    @Test func aTaskCompletedFromOverdueOnTodayCanMoveToTodayButNotWithinOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let completed = task("Buy milk", day: yesterday, sortIndex: 0, completeDay: today)
        let overdue = task("Call mum", day: yesterday, sortIndex: 1)
        let schedule = Schedule(tasks: [completed, overdue], today: today)

        #expect(!schedule.canMove(completed, to: MoveDestination(day: yesterday, after: overdue.id)))
        #expect(schedule.canMove(completed, to: MoveDestination(day: today, after: nil)))
    }

    @Test func aTaskOnTodayCantMoveIntoOverdue() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let overdue = task("Buy milk", day: yesterday, sortIndex: 0)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [overdue, todays], today: today)

        #expect(!schedule.canMove(todays, to: MoveDestination(day: yesterday, after: nil)))
        #expect(!schedule.canMove(todays, to: MoveDestination(day: yesterday, after: overdue.id)))
    }

    @Test func aTaskCanMoveToEveryDayOfTheWindowEmptyOrNot() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let overdue = task("Buy milk", day: yesterday, sortIndex: 0)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [overdue, todays], today: today)

        for windowDay in schedule.days.map(\.day) {
            #expect(schedule.canMove(overdue, to: MoveDestination(day: windowDay, after: nil)))
            #expect(schedule.canMove(todays, to: MoveDestination(day: windowDay, after: nil)))
        }
        #expect(schedule.canMove(overdue, to: MoveDestination(day: today, after: todays.id)))
    }

    @Test func aTaskCanMoveToAListedDayAfterTheWindowButNotToAnUnlistedOne() throws {
        let today = try day("2026-03-01")
        let laterDay = try day("2026-09-01")
        let later = task("Renew passport", day: laterDay, sortIndex: 0)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [todays, later], today: today)

        #expect(schedule.canMove(todays, to: MoveDestination(day: laterDay, after: later.id)))
        #expect(!schedule.canMove(todays, to: MoveDestination(day: try day("2026-09-02"), after: nil)))
    }

    @Test func aHiddenCompleteTaskCantMove() throws {
        let today = try day("2026-03-01")
        let completed = task("Buy milk", day: today, sortIndex: 0, completeDay: today)
        let schedule = Schedule(tasks: [completed], today: today, showsComplete: false)

        #expect(!schedule.canMove(completed, to: MoveDestination(day: today.addingDays(1), after: nil)))
    }

    // MARK: - Steps
    @Test func aStepWithinADayMovesATaskOnePlaceAmongItsDaysTasks() throws {
        let today = try day("2026-03-01")
        let tasks = ["Buy milk", "Call mum", "Walk the dog", "Pay rent"].enumerated().map { index, name in
            task(name, day: today, sortIndex: index)
        }
        let schedule = Schedule(tasks: tasks, today: today)

        #expect(schedule.destinationOneStepUp(for: tasks[2]) == MoveDestination(day: today, after: tasks[0].id))
        #expect(schedule.destinationOneStepUp(for: tasks[1]) == MoveDestination(day: today, after: nil))
        #expect(schedule.destinationOneStepDown(for: tasks[1]) == MoveDestination(day: today, after: tasks[2].id))
    }

    @Test func aStepAtADaysEdgeCrossesIntoTheNeighbouringDay() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let todaysFirst = task("Buy milk", day: today, sortIndex: 0)
        let todaysLast = task("Call mum", day: today, sortIndex: 1)
        let tomorrowsFirst = task("Walk the dog", day: tomorrow, sortIndex: 0)
        let schedule = Schedule(tasks: [todaysFirst, todaysLast, tomorrowsFirst], today: today)

        #expect(schedule.destinationOneStepDown(for: todaysLast) == MoveDestination(day: tomorrow, after: nil))
        #expect(schedule.destinationOneStepUp(for: tomorrowsFirst) == MoveDestination(day: today, after: todaysLast.id))
    }

    @Test func anEmptyDayIsAStopBothWays() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let todays = task("Buy milk", day: today, sortIndex: 0)
        let afterTomorrows = task("Call mum", day: try day("2026-03-03"), sortIndex: 0)
        let schedule = Schedule(tasks: [todays, afterTomorrows], today: today)

        #expect(schedule.destinationOneStepDown(for: todays) == MoveDestination(day: tomorrow, after: nil))
        #expect(schedule.destinationOneStepUp(for: afterTomorrows) == MoveDestination(day: tomorrow, after: nil))
    }

    @Test func anOverdueTasksOnlyStepIsTheTopOfToday() throws {
        let today = try day("2026-03-01")
        let yesterday = try day("2026-02-28")
        let overdue = [
            task("Buy milk", day: yesterday, sortIndex: 0),
            task("Call mum", day: yesterday, sortIndex: 1, completeDay: today),
            task("Walk the dog", day: yesterday, sortIndex: 2),
        ]
        let todays = task("Pay rent", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: overdue + [todays], today: today)

        for task in overdue {
            #expect(schedule.destinationOneStepUp(for: task) == nil)
            #expect(schedule.destinationOneStepDown(for: task) == MoveDestination(day: today, after: nil))
        }
    }

    @Test func theFirstTaskOfTodayHasNoStepUpEvenBelowOverdue() throws {
        let today = try day("2026-03-01")
        let overdue = task("Buy milk", day: try day("2026-02-28"), sortIndex: 0)
        let todays = task("Call mum", day: today, sortIndex: 0)
        let schedule = Schedule(tasks: [overdue, todays], today: today)

        #expect(schedule.destinationOneStepUp(for: todays) == nil)
    }

    @Test func theLastTaskOfTheLastListedDayHasNoStepDown() throws {
        let today = try day("2026-03-01")
        let laterDay = try day("2026-09-01")
        let first = task("Renew passport", day: laterDay, sortIndex: 0)
        let last = task("Book flights", day: laterDay, sortIndex: 1)
        let schedule = Schedule(tasks: [first, last], today: today)

        #expect(schedule.destinationOneStepDown(for: last) == nil)
        #expect(schedule.destinationOneStepDown(for: first) == MoveDestination(day: laterDay, after: last.id))
    }

    @Test func theLastTaskOfTheWindowHasNoStepDownWhenNoLaterDayIsListed() throws {
        let today = try day("2026-03-01")
        let lastWindowTask = task("Buy milk", day: try day("2026-06-08"), sortIndex: 0)
        let schedule = Schedule(tasks: [lastWindowTask], today: today)

        #expect(schedule.destinationOneStepDown(for: lastWindowTask) == nil)
    }

    @Test func aStepAcrossTheWindowsEndReachesAListedLaterDay() throws {
        let today = try day("2026-03-01")
        let lastWindowDay = try day("2026-06-08")
        let laterDay = try day("2026-09-01")
        let lastWindowTask = task("Buy milk", day: lastWindowDay, sortIndex: 0)
        let later = task("Renew passport", day: laterDay, sortIndex: 0)
        let schedule = Schedule(tasks: [lastWindowTask, later], today: today)

        #expect(schedule.destinationOneStepDown(for: lastWindowTask) == MoveDestination(day: laterDay, after: nil))
        let lastOfTheWindow = MoveDestination(day: lastWindowDay, after: lastWindowTask.id)
        #expect(schedule.destinationOneStepUp(for: later) == lastOfTheWindow)
    }

    @Test func aStepSkipsHiddenCompleteTasks() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let first = task("Buy milk", day: today, sortIndex: 0)
        let hidden = task("Call mum", day: today, sortIndex: 1, completeDay: today)
        let last = task("Walk the dog", day: today, sortIndex: 2)
        let hiddenTomorrow = task("Pay rent", day: tomorrow, sortIndex: 0, completeDay: today)
        let tomorrows = task("Book flights", day: tomorrow, sortIndex: 1)
        let schedule = Schedule(
            tasks: [first, hidden, last, hiddenTomorrow, tomorrows], today: today, showsComplete: false
        )

        #expect(schedule.destinationOneStepUp(for: last) == MoveDestination(day: today, after: nil))
        #expect(schedule.destinationOneStepDown(for: first) == MoveDestination(day: today, after: last.id))
        #expect(schedule.destinationOneStepUp(for: tomorrows) == MoveDestination(day: today, after: last.id))
    }

    // MARK: - Drops
    @Test func aTaskDroppedLowerInItsOwnDayGoesAfterTheTaskShownAboveIt() throws {
        let today = try day("2026-03-01")
        let tasks = ["Buy milk", "Call mum", "Walk the dog"].enumerated().map { index, name in
            task(name, day: today, sortIndex: index)
        }
        let schedule = Schedule(tasks: tasks, today: today)

        // Dropped third: below "Call mum" and "Walk the dog" once it's lifted out.
        let destination = schedule.destination(forDropOf: tasks[0], on: today, at: 2)

        #expect(destination == MoveDestination(day: today, after: tasks[2].id))
    }

    @Test func aTaskDroppedAtTheTopOfADayGoesFirst() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let todays = task("Buy milk", day: today, sortIndex: 0)
        let tomorrows = task("Call mum", day: tomorrow, sortIndex: 0)
        let schedule = Schedule(tasks: [todays, tomorrows], today: today)

        let destination = schedule.destination(forDropOf: todays, on: tomorrow, at: 0)

        #expect(destination == MoveDestination(day: tomorrow, after: nil))
    }

    @Test func aTaskCanBeDroppedOnAListedDayButNotOnAnUnlistedOne() throws {
        let today = try day("2026-03-01")
        let todays = task("Buy milk", day: today, sortIndex: 0)
        let tomorrows = task("Call mum", day: try day("2026-03-02"), sortIndex: 0)
        let schedule = Schedule(tasks: [todays, tomorrows], today: today)

        #expect(schedule.canMove(todays, droppedOn: tomorrows.day, at: 1))
        #expect(!schedule.canMove(todays, droppedOn: try day("2026-09-01"), at: 0))
    }

    @Test func aTaskDroppedBetweenTwoShownTasksGoesAfterTheUpperOneWhileCompleteTasksAreHidden() throws {
        let today = try day("2026-03-01")
        let tomorrow = try day("2026-03-02")
        let upper = task("Buy milk", day: today, sortIndex: 0)
        let hidden = task("Call mum", day: today, sortIndex: 1, completeDay: today)
        let lower = task("Walk the dog", day: today, sortIndex: 2)
        let tomorrows = task("Pay rent", day: tomorrow, sortIndex: 0)
        let schedule = Schedule(tasks: [upper, hidden, lower, tomorrows], today: today, showsComplete: false)

        let destination = schedule.destination(forDropOf: tomorrows, on: today, at: 1)

        #expect(destination == MoveDestination(day: today, after: upper.id))
    }
}
