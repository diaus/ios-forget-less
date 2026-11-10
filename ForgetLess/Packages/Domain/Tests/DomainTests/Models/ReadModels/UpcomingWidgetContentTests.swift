import Domain
import Foundation
import Testing

struct UpcomingWidgetContentTests {
    private let today = Date(timeIntervalSince1970: 1_772_323_200) // 2026-03-01, 00:00 GMT

    // MARK: - Tests
    @Test func noTaskOrARowLimitOfNoneIsEmpty() {
        let noTask = UpcomingWidgetContent(tasks: [], today: today, listsTomorrow: true)
        let tasks = [task("Buy milk", day: today)]
        let noRow = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true, rowLimit: 0)

        #expect(noTask == .empty)
        #expect(noRow == .empty)
    }

    @Test func itListsTheFirstTasksUpToTheRowLimitOrAllWithoutOne() {
        let tasks = [task("Buy milk", day: today), task("Call mum", day: today), task("Pay rent", day: today)]

        let limited = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: 2)
        let unlimited = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: nil)

        #expect(rowIDs(of: limited) == tasks.prefix(2).map(\.id))
        #expect(rowIDs(of: unlimited) == tasks.map(\.id))
    }

    @Test func withoutARowLimitNoTaskIsCountedAsLeftOut() {
        let tasks = [task("Pay rent", day: today.addingDays(-1)), task("Buy milk", day: today)]

        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: nil)

        #expect(leftOutTaskCount(of: content) == 0)
    }

    @Test func aRowsStepCanNameATaskPastTheLastRowListed() {
        let tasks = [task("Buy milk", day: today), task("Call mum", day: today)]

        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: 1)

        let belowTheRowLeftOut = MoveDestination(day: today, after: tasks[1].id)
        #expect(rows(of: content).first?.oneStepDestinations.stepDown == belowTheRowLeftOut)
    }

    @Test func overdueAndTomorrowsRowsAreMarkedButTodaysAreNot() {
        let tasks = [
            task("Pay rent", day: today.addingDays(-1)),
            task("Buy milk", day: today),
            task("Walk the dog", day: today.addingDays(1)),
        ]

        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true)

        #expect(rows(of: content).map(\.marker) == [.overdue, nil, .tomorrow])
    }

    @Test func aRowAfterTomorrowIsMarkedAsTomorrowsAre() {
        let content = UpcomingWidgetContent(
            tasks: [task("Renew passport", day: today.addingDays(5))], today: today, listsTomorrow: true
        )

        #expect(rows(of: content).map(\.marker) == [.tomorrow])
    }

    @Test func overdueAndTodaysTasksPastTheRowLimitAreCountedAsLeftOut() {
        let tasks = [
            task("Pay rent", day: today.addingDays(-2)),
            task("Fix the bike", day: today.addingDays(-1)),
            task("Buy milk", day: today),
            task("Call mum", day: today),
        ]

        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: 1)

        #expect(leftOutTaskCount(of: content) == 3)
    }

    @Test func tomorrowsTasksPastTheRowLimitAreNotCountedAsLeftOut() {
        let tasks = [
            task("Buy milk", day: today),
            task("Call mum", day: today),
            task("Walk the dog", day: today.addingDays(1)),
            task("Water the plants", day: today.addingDays(1)),
        ]

        let someTodayLeftOut = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true, rowLimit: 1)
        let onlyTomorrowLeftOut = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true, rowLimit: 2)

        #expect(leftOutTaskCount(of: someTodayLeftOut) == 1)
        #expect(leftOutTaskCount(of: onlyTomorrowLeftOut) == 0)
    }

    // MARK: - Helpers
    private func task(_ name: String, day: Date) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeTime: nil, sortIndex: 0)
    }

    private func rows(of content: UpcomingWidgetContent) -> [UpcomingRow] {
        if case .rows(let rows, _) = content { rows } else { [] }
    }

    private func leftOutTaskCount(of content: UpcomingWidgetContent) -> Int? {
        if case .rows(_, let leftOutTaskCount) = content { leftOutTaskCount } else { nil }
    }

    private func rowIDs(of content: UpcomingWidgetContent) -> [UUID] {
        rows(of: content).map(\.id)
    }
}
