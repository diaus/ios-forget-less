import FactoryKit
import FactoryTesting
import Foundation
import Synchronization
import Testing
@testable import Data

/// The widget reads the store the app writes, and never creates one of its own.
struct StoreReaderTests {
    private let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    private var store: URL { root.appending(path: "Group/Library/Application Support/default.store") }
    // The Day 2026-10-25.
    private let day = Date(timeIntervalSince1970: 1_792_886_400)

    // MARK: - Tests
    @Test func readsTheTasksTheAppStored() async throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try createStoreFolder()
        try await TodoTaskRepositoryLive(modelContainer: try ForgetLessModelContainer.make(url: store))
            .create(name: "Buy milk", day: day)

        let container = try #require(try ForgetLessModelContainer.makeReader(existingStoreAt: store))

        let tasks = try await TodoTaskRepositoryLive(modelContainer: container).tasks(on: day)
        #expect(tasks.map(\.name) == ["Buy milk"])
    }

    @Test(.container) func aWriteThroughTheReaderFailsAndRunsNoAfterSaveHook() async throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try createStoreFolder()
        _ = try ForgetLessModelContainer.make(url: store)
        let saves = Mutex(0)
        Container.shared.afterStoreSave.register { { saves.withLock { $0 += 1 } } }
        let reader = TodoTaskRepositoryLive(
            modelContainer: try #require(try ForgetLessModelContainer.makeReader(existingStoreAt: store))
        )

        await #expect(throws: (any Error).self) {
            try await reader.create(name: "Buy milk", day: day)
        }

        #expect(saves.withLock { $0 } == 0)
    }

    @Test func opensNothingAndCreatesNoStoreWhileThereIsNone() throws {
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(try ForgetLessModelContainer.makeReader(existingStoreAt: store) == nil)
        #expect(!FileManager.default.fileExists(atPath: store.path(percentEncoded: false)))
    }

    // MARK: - Helpers
    private func createStoreFolder() throws {
        let folder = store.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }
}
