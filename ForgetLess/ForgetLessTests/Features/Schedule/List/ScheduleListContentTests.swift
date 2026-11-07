import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct ScheduleListContentTests {
    /// Any Day: the rules read Days only against it.
    private let today = Date(timeIntervalSince1970: 0)

    // MARK: - Tests
    @Test func theSameTasksOnTheSameTodayNeedNoRedraw() {
        let tasks = [task("Buy milk", day: 0, sortIndex: 0), task("Call Mum", day: 1, sortIndex: 0)]

        let redraw = content(tasks).redraw(from: content(tasks))

        #expect(redraw == nil)
    }

    @Test func aRenamedTaskIsRedrawnInPlace() {
        let renamed = task("Buy milk", day: 0, sortIndex: 0)
        let other = task("Call Mum", day: 0, sortIndex: 1)
        var newName = renamed
        newName.name = "Buy oat milk"

        let redraw = content([newName, other]).redraw(from: content([renamed, other]))

        #expect(redraw == ScheduleListRedraw(reconfiguredTaskIDs: [renamed.id], reloadedTaskIDs: []))
    }

    @Test func aTaskThatTurnsOverdueAsTodayRollsOverIsReloadedNotRedrawnInPlace() {
        let turningOverdue = task("Buy milk", day: 0, sortIndex: 0)
        let tomorrow = today.addingDays(1)

        let redraw = content([turningOverdue], today: tomorrow).redraw(from: content([turningOverdue]))

        #expect(redraw == ScheduleListRedraw(reconfiguredTaskIDs: [], reloadedTaskIDs: [turningOverdue.id]))
    }

    @Test func aNewTodayAloneIsARedrawOfNoRow() {
        let later = task("Buy milk", day: 5, sortIndex: 0)

        let redraw = content([later], today: today.addingDays(1)).redraw(from: content([later]))

        #expect(redraw == ScheduleListRedraw(reconfiguredTaskIDs: [], reloadedTaskIDs: []))
    }

    @Test func aNewlyListedTaskIsNoRedraw() {
        let listed = task("Buy milk", day: 0, sortIndex: 0)
        let added = task("Call Mum", day: 0, sortIndex: 1)

        let redraw = content([listed, added]).redraw(from: content([listed]))

        #expect(redraw == nil)
    }

    // MARK: - Helpers
    /// What the list shows of `tasks` on `today`, or on this suite's Today.
    private func content(_ tasks: [TodoTask], today: Date? = nil) -> ScheduleListContent {
        let today = today ?? self.today
        return ScheduleListContent(schedule: Schedule(tasks: tasks, today: today), today: today)
    }

    private func task(_ name: String, day dayCount: Int, sortIndex: Int) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: today.addingDays(dayCount), completeDay: nil, sortIndex: sortIndex)
    }
}
