import Foundation

/// Adds a Task, Incomplete, at the end of its Day, with its name trimmed by the name rule.
public struct AddTask: Sendable {
    private let repository: any TodoTaskRepository

    public init(repository: any TodoTaskRepository) {
        self.repository = repository
    }

    /// Throws `DomainError.emptyName`, creating nothing, when the name is empty after trimming.
    public func callAsFunction(name: String, day: Date) async throws {
        let name = try validatedTaskName(name)
        let tasksOfDay = try await repository.tasks(on: day)
        let task = TodoTask(
            id: UUID(),
            name: name,
            day: day,
            isComplete: false,
            sortIndex: TodoTask.nextSortIndex(in: tasksOfDay)
        )
        try await repository.create(task)
    }
}
