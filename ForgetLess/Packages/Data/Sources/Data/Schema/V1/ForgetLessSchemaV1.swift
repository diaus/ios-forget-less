import Foundation
import SwiftData

/// The first stored schema, versioned from day one so a later change can migrate.
enum ForgetLessSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TodoTaskModel.self]
    }

    /// A stored Task.
    @Model
    final class TodoTaskModel {
        @Attribute(.unique) var id: UUID
        var name: String
        var day: Date
        var isComplete: Bool
        var sortIndex: Int

        init(id: UUID, name: String, day: Date, isComplete: Bool, sortIndex: Int) {
            self.id = id
            self.name = name
            self.day = day
            self.isComplete = isComplete
            self.sortIndex = sortIndex
        }
    }
}

/// The stored Task of the current schema version.
typealias TodoTaskModel = ForgetLessSchemaV1.TodoTaskModel
