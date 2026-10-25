import Domain
import Foundation
import Testing

struct AddTaskTests {
    private let today = Date(timeIntervalSinceReferenceDate: 0)
    private var tomorrow: Date { today.addingTimeInterval(24 * 60 * 60) }

    @Test func addTaskAppendsAnIncompleteTaskAtTheEndOfItsDay() async throws {
        let repository = FakeTodoTaskRepository(tasks: [
            task(day: today, sortIndex: 0),
            task(day: today, sortIndex: 4),
            task(day: tomorrow, sortIndex: 9),
        ])

        try await AddTask(repository: repository)(name: "  Buy milk \n", day: today)

        let added = try #require(await repository.tasks.last)
        #expect(added.name == "Buy milk")
        #expect(added.day == today)
        #expect(added.sortIndex == 5)
        #expect(!added.isComplete)
        #expect(await repository.tasks.count == 4)
    }

    @Test func addTaskStartsAnEmptyDayAtSortIndexZero() async throws {
        let repository = FakeTodoTaskRepository(tasks: [task(day: tomorrow, sortIndex: 3)])

        try await AddTask(repository: repository)(name: "Buy milk", day: today)

        #expect(await repository.tasks.last?.sortIndex == 0)
    }

    @Test func addTaskRefusesAnEmptyNameAndCreatesNothing() async {
        let repository = FakeTodoTaskRepository()

        await #expect(throws: DomainError.emptyName) {
            try await AddTask(repository: repository)(name: " \n ", day: today)
        }
        #expect(await repository.tasks.isEmpty)
    }

    private func task(day: Date, sortIndex: Int) -> TodoTask {
        TodoTask(id: UUID(), name: "Existing", day: day, isComplete: false, sortIndex: sortIndex)
    }
}
