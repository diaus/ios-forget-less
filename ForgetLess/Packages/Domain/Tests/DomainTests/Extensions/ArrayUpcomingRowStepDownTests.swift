import Domain
import Foundation
import Testing

struct ArrayUpcomingRowStepDownTests {
    private let today = Date(timeIntervalSince1970: 1_772_323_200) // 2026-03-01, 00:00 GMT

    // MARK: - Tests
    @Test func withEveryRowShownARowStepsDownPastTheTaskBelow() {
        let tasks = [task("Buy milk"), task("Call mum")]
        let rows = rows(for: tasks)

        #expect(rows.stepDown(ofRowAt: 0, shownRowCount: 2) == MoveDestination(day: today, after: tasks[1].id))
    }

    @Test func theLastRowShownCanNotStepDownPastARowLeftOut() {
        let rows = rows(for: [task("Buy milk"), task("Call mum")])

        #expect(rows.stepDown(ofRowAt: 0, shownRowCount: 1) == nil)
    }

    @Test func aRowAboveOnlyKeptRowsCanNotStepDownPastARowLeftOut() {
        let rows = rows(for: [task("Buy milk"), task("Call mum", isComplete: true), task("Pay rent")])

        #expect(rows.stepDown(ofRowAt: 0, shownRowCount: 2) == nil)
    }

    @Test func aRowAboveAShownIncompleteRowStepsDownPastItWhileRowsAreLeftOut() {
        let tasks = [task("Buy milk"), task("Call mum", isComplete: true), task("Pay rent"), task("Walk the dog")]
        let rows = rows(for: tasks)

        #expect(rows.stepDown(ofRowAt: 0, shownRowCount: 3) == MoveDestination(day: today, after: tasks[2].id))
    }

    // MARK: - Helpers
    private func task(_ name: String, isComplete: Bool = false) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: today, completeTime: isComplete ? today : nil, sortIndex: 0)
    }

    private func rows(for tasks: [TodoTask]) -> [UpcomingRow] {
        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: nil)
        if case .rows(let rows, _) = content { return rows }
        return []
    }
}
