import Foundation
import Utils

/// Gives a Task a new name.
public struct RenameTask: Sendable {
    private let repository: any TodoTaskRepository

    public init(repository: any TodoTaskRepository) {
        self.repository = repository
    }

    /// Throws `DomainError.emptyName` for a blank name.
    public func callAsFunction(id: UUID, name: String) async throws {
        let name = name.trimmed
        guard !name.isEmpty else { throw DomainError.emptyName }
        try await repository.rename(id: id, name: name)
    }
}
