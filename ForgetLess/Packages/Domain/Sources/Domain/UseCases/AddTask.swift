import Foundation

/// Adds a new Task to its Day.
public struct AddTask: Sendable {
    private let repository: any TodoTaskRepository

    public init(repository: any TodoTaskRepository) {
        self.repository = repository
    }

    /// Throws `DomainError.emptyName` for a blank name.
    public func callAsFunction(name: String, day: Date) async throws {
        guard let name = TodoTask.savedName(from: name) else { throw DomainError.emptyName }
        try await repository.create(name: name, day: day)
    }
}
