import Foundation
import SwiftData

/// Builds the app's `ModelContainer`.
public enum ForgetLessModelContainer {
    static let schema = Schema(versionedSchema: ForgetLessSchemaV1.self)

    /// The on-disk store the app uses, or an in-memory one for tests and previews.
    public static func make(inMemory: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            #if targetEnvironment(simulator)
            // V1 is edited in place until the first release, so an older store may not open. The simulator holds no
            // real data, so it starts over; a device never wipes, since a Debug build can replace a TestFlight install.
            removeStore(at: configuration.url)
            return try ModelContainer(for: schema, configurations: configuration)
            #else
            throw error
            #endif
        }
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
