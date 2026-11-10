import Domain
import Foundation
import Testing

struct ArrayGracePeriodEndTests {
    private let today = Date(timeIntervalSince1970: 1_772_323_200) // 2026-03-01, 00:00 GMT
    private let rollover = Date(timeIntervalSince1970: 1_772_409_600) // 2026-03-02, 00:00 GMT

    // MARK: - Tests
    @Test func aCompleteTaskLeavesWhenItsGracePeriodEndsAndAnIncompleteOneNever() {
        let completeTime = today.addingTimeInterval(60)
        let tasks = [task("Buy milk", completeTime: completeTime), task("Call mum", completeTime: nil)]

        #expect(tasks.gracePeriodEnds(lasting: 5, before: rollover) == [today.addingTimeInterval(65)])
    }

    @Test func aGracePeriodEndingAtOrAfterTheEndIsLeftOut() {
        let tasks = [
            task("Buy milk", completeTime: rollover.addingTimeInterval(-5)),
            task("Call mum", completeTime: rollover.addingTimeInterval(-3)),
        ]

        #expect(tasks.gracePeriodEnds(lasting: 5, before: rollover).isEmpty)
    }

    @Test func theEndsAreInOrderAndEachOnce() {
        let tasks = [
            task("Buy milk", completeTime: today.addingTimeInterval(30)),
            task("Call mum", completeTime: today.addingTimeInterval(10)),
            task("Pay rent", completeTime: today.addingTimeInterval(30)),
        ]

        let ends = tasks.gracePeriodEnds(lasting: 5, before: rollover)

        #expect(ends == [today.addingTimeInterval(15), today.addingTimeInterval(35)])
    }

    // MARK: - Helpers
    private func task(_ name: String, completeTime: Date?) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: today, completeTime: completeTime, sortIndex: 0)
    }
}
