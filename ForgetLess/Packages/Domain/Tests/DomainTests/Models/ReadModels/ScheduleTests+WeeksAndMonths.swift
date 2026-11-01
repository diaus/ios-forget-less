import Domain
import Foundation
import Testing

/// Where the Schedule's weeks and months start.
extension ScheduleTests {
    // MARK: - Weeks
    @Test(arguments: [1, 2])
    func todayNeverStartsAWeekEvenOnTheFirstWeekday(firstWeekday: Int) throws {
        // A Sunday, then a Monday.
        for today in [try day("2026-11-01"), try day("2026-11-02")] {
            let schedule = Schedule(tasks: [], today: today, firstWeekday: firstWeekday)

            #expect(!schedule.days[0].startsWeek)
        }
    }

    @Test(arguments: [(1, "2026-11-08"), (2, "2026-11-02")])
    func inTheWindowOnlyTheFirstWeekdayStartsAWeek(firstWeekday: Int, firstWeekStart: String) throws {
        let today = try day("2026-11-01")

        let schedule = Schedule(tasks: [], today: today, firstWeekday: firstWeekday)

        let weekStarts = schedule.days.filter(\.startsWeek).map(\.day)
        let firstStart = try day(firstWeekStart)
        let expected = stride(from: 0, to: 100, by: 7)
            .map { firstStart.addingDays($0) }
            .filter { $0 <= today.addingDays(99) }
        #expect(weekStarts == expected)
    }

    @Test func aDayAfterTheWindowStartsAWeekWhenTheDayListedBeforeIsInAnotherOne() throws {
        // The window runs through Monday 2027-02-08.
        let today = try day("2026-11-01")
        let tasks = [
            task("Same week", day: try day("2027-02-10"), sortIndex: 0),
            task("A week on, mid-week", day: try day("2027-02-17"), sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today, firstWeekday: 2)

        #expect(schedule.days.dropFirst(100).map(\.startsWeek) == [false, true])
    }

    // MARK: - Months
    @Test func theFirstOfEachMonthInTheWindowStartsAMonth() throws {
        let today = try day("2026-11-10")

        let schedule = Schedule(tasks: [], today: today)

        let monthStarts = schedule.days.filter(\.startsMonth).map(\.day)
        #expect(monthStarts == [try day("2026-12-01"), try day("2027-01-01"), try day("2027-02-01")])
    }

    @Test(arguments: [("2026-11-01", true), ("2026-11-02", false)])
    func todayStartsAMonthOnlyOnTheFirst(today: String, startsMonth: Bool) throws {
        let schedule = Schedule(tasks: [], today: try day(today))

        #expect(schedule.days[0].startsMonth == startsMonth)
    }

    @Test func aDayAfterTheWindowStartsAMonthWhenTheDayListedBeforeIsInAnotherOne() throws {
        // The window runs through 2027-02-08.
        let today = try day("2026-11-01")
        let tasks = [
            task("Same month", day: try day("2027-02-20"), sortIndex: 0),
            task("Next month, mid-month", day: try day("2027-03-15"), sortIndex: 0),
        ]

        let schedule = Schedule(tasks: tasks, today: today)

        #expect(schedule.days.dropFirst(100).map(\.startsMonth) == [false, true])
    }
}
