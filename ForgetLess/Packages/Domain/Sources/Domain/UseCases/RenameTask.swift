import Foundation

/// Gives a Task a new name.
public struct RenameTask: Sendable {
    private let repository: any TodoTaskRepository

    public init(repository: any TodoTaskRepository) {
        self.repository = repository
    }

    /// Throws `DomainError.emptyName` for a blank name.
    public func callAsFunction(id: UUID, name: String) async throws {
        guard let name = TodoTask.savedName(from: name) else { throw DomainError.emptyName }
        try await repository.rename(id: id, name: name)
    }
}
