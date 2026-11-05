import Foundation
import SwiftData

/// Builds the app's `ModelContainer`.
public enum ForgetLessModelContainer {
    static let schema = Schema(versionedSchema: ForgetLessSchemaV1.self)

    /// An in-memory store, for tests and previews.
    public static func makeInMemory() throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true))
    }

    /// The on-disk store the app writes, in the App Group the widget shares (ADR 0003). Creates it when there is none.
    public static func makeInAppGroup() throws -> ModelContainer {
        let url = try ForgetLessStoreLocation.appGroupStoreURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        return try make(url: url)
    }

    /// The store at `url`, created when there is none.
    static func make(url: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, url: url)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            #if targetEnvironment(simulator)
            // V1 is edited in place until the first release, so an older store may not open. The simulator holds no
            // real data, so it starts over; a device never wipes, since a Debug build can replace a TestFlight install.
            removeStore(at: url)
            return try ModelContainer(for: schema, configurations: configuration)
            #else
            throw error
            #endif
        }
    }

    /// The store at `url`, read-only unless `allowsSave`, or nil when there is none, in which case nothing is
    /// created. A store that won't open throws and is left as it is.
    static func makeExisting(at url: URL, allowsSave: Bool) throws -> ModelContainer? {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return nil }
        let configuration = ModelConfiguration(schema: schema, url: url, allowsSave: allowsSave)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    // MARK: - Helpers
    #if targetEnvironment(simulator)
    private static func removeStore(at url: URL) {
        for suffix in ["", "-wal", "-shm"] {
            let file = url.deletingLastPathComponent().appending(component: url.lastPathComponent + suffix)
            try? FileManager.default.removeItem(at: file)
        }
    }
    #endif
}
