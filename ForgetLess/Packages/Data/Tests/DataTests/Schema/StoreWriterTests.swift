import Foundation
import Testing
@testable import Data

/// The widget writes to the store the app created, and never creates one of its own (ADR 0005).
struct StoreWriterTests {
    private let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    private var store: URL { root.appending(path: "Group/Library/Application Support/default.store") }
    // The Day 2026-10-25.
    private let day = Date(timeIntervalSince1970: 1_792_886_400)

    // MARK: - Tests
    @Test func aWriteThroughTheWriterReachesAFreshReader() async throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try createStoreFolder()
        let app = TodoTaskRepositoryLive(modelContainer: try ForgetLessModelContainer.make(url: store))
        try await app.create(name: "Buy milk", day: day)
        let id = try #require(try await app.tasks(on: day).first?.id)
        let writer = TodoTaskRepositoryLive(
            modelContainer: try #require(try ForgetLessModelContainer.makeWriter(existingStoreAt: store))
        )

        try await writer.setComplete(id: id, isComplete: true, today: day)

        let reader = TodoTaskRepositoryLive(
            modelContainer: try #require(try ForgetLessModelContainer.makeReader(existingStoreAt: store))
        )
        #expect(try await reader.tasks(on: day).map(\.completeDay) == [day])
    }

    @Test func opensNothingAndCreatesNoStoreWhileThereIsNone() throws {
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(try ForgetLessModelContainer.makeWriter(existingStoreAt: store) == nil)
        #expect(!FileManager.default.fileExists(atPath: store.path(percentEncoded: false)))
    }

    // MARK: - Helpers
    private func createStoreFolder() throws {
        let folder = store.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }
}
