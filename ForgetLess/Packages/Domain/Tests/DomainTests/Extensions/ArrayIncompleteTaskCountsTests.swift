import Domain
import Foundation
import Testing

struct ArrayIncompleteTaskCountsTests {
    // MARK: - Tests
    @Test func onlyIncompleteTasksCount() throws {
        let today = try day("2026-11-01")
        let tasks = [
            task("Buy milk", day: today),
            task("Call mum", day: today, completeDay: today),
            task("Walk the dog", day: today),
        ]

        #expect(tasks.incompleteTaskCountsByDay == [today: 2])
    }

    @Test func eachTaskCountsOnItsOwnDay() throws {
        let today = try day("2026-11-01")
        let tomorrow = try day("2026-11-02")
        let nextYear = try day("2027-01-01")
        let tasks = [
            task("Buy milk", day: today),
            task("Call mum", day: tomorrow),
            task("Walk the dog", day: tomorrow),
            task("Pay rent", day: nextYear),
        ]

        #expect(tasks.incompleteTaskCountsByDay == [today: 1, tomorrow: 2, nextYear: 1])
    }

    @Test func aDayWithOnlyCompleteTasksHasNoCount() throws {
        let today = try day("2026-11-01")
        let tomorrow = try day("2026-11-02")
        let tasks = [
            task("Buy milk", day: today),
            task("Call mum", day: tomorrow, completeDay: today),
            task("Walk the dog", day: tomorrow, completeDay: today),
        ]

        #expect(tasks.incompleteTaskCountsByDay[tomorrow] == nil)
    }

    // MARK: - Helpers
    private func task(_ name: String, day: Date, completeDay: Date? = nil) -> TodoTask {
        TodoTask(id: UUID(), name: name, day: day, completeDay: completeDay, sortIndex: 0)
    }

    /// The Day `yyyy-MM-dd`, as 00:00 GMT.
    private func day(_ yearMonthDay: String) throws -> Date {
        try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)
    }
}
