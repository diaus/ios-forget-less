import SwiftData

/// The first stored schema. It's versioned from day one so a later change can migrate; the Task model joins it with
/// the first stored Task.
enum ForgetLessSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        []
    }
}
