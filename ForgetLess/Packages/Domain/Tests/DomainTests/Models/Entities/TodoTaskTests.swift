import Domain
import Foundation
import Testing

struct TodoTaskTests {
    private let day = Date(timeIntervalSinceReferenceDate: 0)

    // MARK: - Tests
    @Test func anEmptyDayStartsAtSortIndexZero() {
        #expect(TodoTask.nextSortIndex(in: []) == 0)
    }

    @Test func theNextTaskGoesAfterTheHighestSortIndexOfItsDay() {
        let tasksOfDay = [task(sortIndex: 4), task(sortIndex: 0), task(sortIndex: 2)]

        #expect(TodoTask.nextSortIndex(in: tasksOfDay) == 5)
    }

    // MARK: - Helpers
    private func task(sortIndex: Int) -> TodoTask {
        TodoTask(id: UUID(), name: "Buy milk", day: day, isComplete: false, sortIndex: sortIndex)
    }
}
