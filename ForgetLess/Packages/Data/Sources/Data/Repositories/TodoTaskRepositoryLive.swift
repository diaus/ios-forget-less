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
    /// Runs after every successful save, for readers in another process, such as the widget (ADR 0003).
    private let afterStoreSave: @Sendable () -> Void
    private let logger = Logger(subsystem: "ForgetLess.Data", category: "TodoTaskRepository")
    /// The Schedule's order, which every list of Tasks the repository returns comes in.
    private static let scheduleOrder = [SortDescriptor(\TodoTaskModel.day), SortDescriptor(\TodoTaskModel.sortIndex)]

    init(modelContainer: ModelContainer, afterStoreSave: @escaping @Sendable () -> Void = {}) {
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.modelContainer = modelContainer
        self.afterStoreSave = afterStoreSave
    }

    // MARK: - TodoTaskRepository
    func tasks(on day: Date) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTaskModel>(
            predicate: #Predicate { $0.day == day },
            sortBy: Self.scheduleOrder
        )
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

    func incompleteTasks(from firstDay: Date?, through lastDay: Date) throws -> [TodoTask] {
        let firstDay = firstDay ?? .distantPast
        let descriptor = FetchDescriptor<TodoTaskModel>(
            predicate: #Predicate { $0.completeDay == nil && $0.day >= firstDay && $0.day <= lastDay },
            sortBy: Self.scheduleOrder
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
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

    func move(id: UUID, to destination: MoveDestination) throws {
        // Read and write without suspending, so two moves at once can't take the same place in the Day.
        guard let model = try model(id: id) else { return }
        let day = destination.day
        let modelsOfDay = try modelContext.fetch(FetchDescriptor<TodoTaskModel>(
            predicate: #Predicate { $0.day == day },
            sortBy: Self.scheduleOrder
        ))
        let tasksOfDay = modelsOfDay.map { $0.toDomain() }
        let order = TodoTask.order(afterMoving: model.toDomain(), to: destination, in: tasksOfDay)
        var modelsByID = Dictionary(uniqueKeysWithValues: modelsOfDay.map { ($0.id, $0) })
        modelsByID[model.id] = model
        for (sortIndex, task) in order.enumerated() {
            modelsByID[task.id]?.sortIndex = sortIndex
        }
        model.day = day
        try saveAndNotify()
    }

    func delete(id: UUID) throws {
        guard let model = try model(id: id) else { return }
        modelContext.delete(model)
        try saveAndNotify()
    }

    // MARK: - Helpers
    private func fetchScheduleTasks(today: Date) throws -> [TodoTask] {
        // An Incomplete Task has no `completeDay`, so it counts as completed on no Day yet.
        let distantFuture = Date.distantFuture
        let descriptor = FetchDescriptor<TodoTaskModel>(
            predicate: #Predicate { $0.day >= today || ($0.completeDay ?? distantFuture) >= today },
            sortBy: Self.scheduleOrder
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
        afterStoreSave()
    }
}
