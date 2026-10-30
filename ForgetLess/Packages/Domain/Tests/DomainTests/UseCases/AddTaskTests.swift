import Domain
import Foundation
import Testing

struct AddTaskTests {
    private let today = Date(timeIntervalSinceReferenceDate: 0)

    @Test func addTaskCreatesAnIncompleteTaskWithTheTrimmedNameOnItsDay() async throws {
        let repository = FakeTodoTaskRepository()

        try await AddTask(repository: repository)(name: "  Buy milk \n", day: today)

        let added = try #require(await repository.tasks.first)
        #expect(added.name == "Buy milk")
        #expect(added.day == today)
        #expect(!added.isComplete)
        #expect(await repository.tasks.count == 1)
    }

    @Test func addTaskRefusesAnEmptyNameAndCreatesNothing() async {
        let repository = FakeTodoTaskRepository()

        await #expect(throws: DomainError.emptyName) {
            try await AddTask(repository: repository)(name: " \n ", day: today)
        }
        #expect(await repository.tasks.isEmpty)
    }
}
