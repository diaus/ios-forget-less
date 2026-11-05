import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct ScheduleTasksTests {
    /// Any Day: the rules read Days only against it.
    private let today = Date(timeIntervalSince1970: 0)

    // MARK: - Tests
    @Test func aMoveListsTheTaskAtItsDestinationBeforeTheStoreHasIt() {
        let (first, second) = (task("Buy milk", day: 0, sortIndex: 0), task("Call Mum", day: 0, sortIndex: 1))
        let scheduleTasks = observed([first, second])
        let destination = MoveDestination(day: today.addingDays(1), after: nil)

        let moved = scheduleTasks.move(first, to: destination)

        #expect(moved)
        #expect(scheduleTasks.task(withID: first.id)?.day == today.addingDays(1))
        #expect(names(on: 0, in: scheduleTasks) == ["Call Mum"])
        #expect(names(on: 1, in: scheduleTasks) == ["Buy milk"])
    }

    @Test func aMoveToTheEndOfADayListsTheTaskLastThere() {
        let moving = task("Buy milk", day: 0, sortIndex: 0)
        let other = task("Call Mum", day: 2, sortIndex: 0)
        let scheduleTasks = observed([moving, other])

        let destination = scheduleTasks.moveToEnd(moving, of: today.addingDays(2))

        #expect(destination == MoveDestination(day: today.addingDays(2), after: other.id))
        #expect(names(on: 2, in: scheduleTasks) == ["Call Mum", "Buy milk"])
    }

    @Test func droppingUnsavedMovesListsTheTasksAsTheStoreLastHeldThem() {
        let moving = task("Buy milk", day: 0, sortIndex: 0)
        let scheduleTasks = observed([moving])
        _ = scheduleTasks.moveToEnd(moving, of: today.addingDays(3))

        scheduleTasks.dropUnsavedMoves()

        #expect(scheduleTasks.task(withID: moving.id)?.day == today)
        #expect(names(on: 0, in: scheduleTasks) == ["Buy milk"])
        #expect(names(on: 3, in: scheduleTasks).isEmpty)
    }

    @Test func observingTasksReplacesAnyUnsavedMove() {
        let moving = task("Buy milk", day: 0, sortIndex: 0)
        let scheduleTasks = observed([moving])
        _ = scheduleTasks.moveToEnd(moving, of: today.addingDays(3))
        let stored = task("Buy milk", id: moving.id, day: 5, sortIndex: 0)

        scheduleTasks.observe([stored])

        #expect(names(on: 3, in: scheduleTasks).isEmpty)
        #expect(names(on: 5, in: scheduleTasks) == ["Buy milk"])
    }

    @Test(arguments: [-1, -30])
    func aMoveToTheEndOfADayBeforeTodayIsRefusedAndMovesNothing(dayCount: Int) {
        let moving = task("Buy milk", day: 0, sortIndex: 0)
        let scheduleTasks = observed([moving])

        let destination = scheduleTasks.moveToEnd(moving, of: today.addingDays(dayCount))

        #expect(destination == nil)
        #expect(scheduleTasks.task(withID: moving.id)?.day == today)
    }

    @Test func aMoveOfATaskTheScheduleDoesNotListIsRefusedAndMovesNothing() {
        let hidden = task("Buy milk", day: 0, sortIndex: 0, isComplete: true)
        let scheduleTasks = observed([hidden]) { listing(showsComplete: false) }

        let moved = scheduleTasks.move(hidden, to: MoveDestination(day: today.addingDays(1), after: nil))

        #expect(!moved)
        #expect(scheduleTasks.task(withID: hidden.id)?.day == today)
    }

    @Test func relistingReadsTheListingAfreshSoATaskKeptSinceIsListedWhileCompleteTasksAreHidden() {
        let complete = task("Buy milk", day: 0, sortIndex: 0, isComplete: true)
        let scheduleTasks = observed([complete]) { listing(showsComplete: false) }
        #expect(names(on: 0, in: scheduleTasks).isEmpty)

        scheduleTasks.listing = { listing(showsComplete: false, keptTaskIDs: [complete.id]) }
        scheduleTasks.relist()

        #expect(names(on: 0, in: scheduleTasks) == ["Buy milk"])
    }

    @Test func itCountsTheIncompleteTasksOfEachDayItLists() {
        let tasks = [
            task("Buy milk", day: 0, sortIndex: 0),
            task("Call Mum", day: 0, sortIndex: 1, isComplete: true),
            task("Pay rent", day: 1, sortIndex: 0),
        ]
        let scheduleTasks = observed(tasks)

        _ = scheduleTasks.moveToEnd(tasks[2], of: today)

        #expect(scheduleTasks.incompleteTaskCountsByDay == [today: 2])
    }

    // MARK: - Helpers
    private func listing(showsComplete: Bool = true, keptTaskIDs: Set<UUID> = []) -> ScheduleListing {
        ScheduleListing(today: today, showsComplete: showsComplete, keptTaskIDs: keptTaskIDs)
    }

    /// Tasks that have observed `tasks`, listed by `listingNow`, or with every Task listed.
    private func observed(
        _ tasks: [TodoTask], listedBy listingNow: (@MainActor () -> ScheduleListing)? = nil
    ) -> ScheduleTasks {
        let scheduleTasks = ScheduleTasks(today: today)
        scheduleTasks.listing = listingNow ?? { listing() }
        scheduleTasks.observe(tasks)
        return scheduleTasks
    }

    private func task(
        _ name: String, id: UUID = UUID(), day dayCount: Int, sortIndex: Int, isComplete: Bool = false
    ) -> TodoTask {
        let day = today.addingDays(dayCount)
        return TodoTask(id: id, name: name, day: day, completeDay: isComplete ? day : nil, sortIndex: sortIndex)
    }

    /// The names of the Tasks the Schedule lists on the Day `dayCount` Days from Today, in order.
    private func names(on dayCount: Int, in scheduleTasks: ScheduleTasks) -> [String] {
        let day = today.addingDays(dayCount)
        return scheduleTasks.schedule.days.first { $0.day == day }?.tasks.map(\.name) ?? []
    }
}
