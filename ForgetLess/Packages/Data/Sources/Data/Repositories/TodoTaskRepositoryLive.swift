import Domain
import Foundation
import os
import SwiftData
import Utils

/// The SwiftData `TodoTaskRepository`.
actor TodoTaskRepositoryLive: TodoTaskRepository, ModelActor {
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer
    /// Tells the open `scheduleTasks(today:)` streams that the store changed.
    private let notifier = ChangeNotifier()
    private let logger = Logger(subsystem: "ForgetLess.Data", category: "TodoTaskRepository")

    init(modelContainer: ModelContainer) {
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.modelContainer = modelContainer
    }

    // MARK: - TodoTaskRepository
    func tasks(on day: Date) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day == day })
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func scheduleTasks(today: Date) throws -> AsyncStream<[TodoTask]> {
        // Subscribed before the first fetch, so a write during it still sends.
        let changes = notifier.changes
        let first = try fetchScheduleTasks(today: today)
        let (stream, continuation) = AsyncStream.makeStream(of: [TodoTask].self, bufferingPolicy: .bufferingNewest(1))
        continuation.yield(first)
        let refetching = Task { [weak self] in
            for await _ in changes {
                guard let self else { break }
                do {
                    continuation.yield(try await fetchScheduleTasks(today: today))
                } catch {
                    // The consumer keeps the last Tasks it got; the next change fetches again.
                    logger.error("Could not fetch the Schedule's Tasks: \(String(describing: error))")
                }
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in refetching.cancel() }
        return stream
    }

    func create(name: String, day: Date) throws {
        // Read and insert without suspending, so two creates at once can't take the same place in the Day.
        let task = TodoTask(
            id: UUID(),
            name: name,
            day: day,
            completeDay: nil,
            sortIndex: TodoTask.nextSortIndex(in: try tasks(on: day))
        )
        modelContext.insert(TodoTaskModel(task))
        try saveAndNotify()
    }

    func rename(id: UUID, name: String) throws {
        guard let model = try model(id: id) else { return }
        model.name = name
        try saveAndNotify()
    }

    func setComplete(id: UUID, isComplete: Bool, today: Date) throws {
        guard let model = try model(id: id) else { return }
        model.completeDay = isComplete ? today : nil
        try saveAndNotify()
    }

    // MARK: - Helpers
    private func fetchScheduleTasks(today: Date) throws -> [TodoTask] {
        // An Incomplete Task has no `completeDay`, so it counts as completed on no Day yet.
        let distantFuture = Date.distantFuture
        let descriptor = FetchDescriptor<TodoTaskModel>(
            predicate: #Predicate { $0.day >= today || ($0.completeDay ?? distantFuture) >= today }
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    private func model(id: UUID) throws -> TodoTaskModel? {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }

    /// Saves, or discards every unsaved change when the save fails so the next write starts clean.
    private func saveAndNotify() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
        notifier.notify()
    }
}
