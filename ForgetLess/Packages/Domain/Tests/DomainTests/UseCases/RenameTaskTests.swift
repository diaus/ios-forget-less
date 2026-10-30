import Domain
import Foundation
import Testing

struct RenameTaskTests {
    private let today = Date(timeIntervalSinceReferenceDate: 0)

    @Test func renameTaskSavesTheTrimmedName() async throws {
        let repository = FakeTodoTaskRepository()
        await repository.create(name: "Buy milk", day: today)
        let task = try #require(await repository.tasks.first)

        try await RenameTask(repository: repository)(id: task.id, name: "  Buy oat milk \n")

        #expect(await repository.tasks.first?.name == "Buy oat milk")
    }

    @Test func renameTaskRefusesAnEmptyNameAndKeepsTheOldOne() async throws {
        let repository = FakeTodoTaskRepository()
        await repository.create(name: "Buy milk", day: today)
        let task = try #require(await repository.tasks.first)

        await #expect(throws: DomainError.emptyName) {
            try await RenameTask(repository: repository)(id: task.id, name: " \n ")
        }
        #expect(await repository.tasks.first?.name == "Buy milk")
    }
}
