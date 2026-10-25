import SwiftData

/// Builds the app's `ModelContainer` for the current schema version.
public enum ForgetLessModelContainer {
    static let schema = Schema(versionedSchema: ForgetLessSchemaV1.self)

    /// The on-disk store the app uses, or an in-memory one for tests and previews.
    public static func make(inMemory: Bool) throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory))
    }
}
