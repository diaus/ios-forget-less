import Domain
import Foundation
import SwiftData

/// The SwiftData `TodoTaskRepository`.
actor TodoTaskRepositoryLive: TodoTaskRepository, ModelActor {
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.modelContainer = modelContainer
    }

    // MARK: - TodoTaskRepository
    func tasks(on day: Date) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day == day })
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func tasks(onOrAfter day: Date) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day >= day })
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func create(name: String, day: Date) throws {
        // Read and insert without suspending, so two creates at once can't take the same place in the Day.
        let task = TodoTask(
            id: UUID(),
            name: name,
            day: day,
            isComplete: false,
            sortIndex: TodoTask.nextSortIndex(in: try tasks(on: day))
        )
        modelContext.insert(TodoTaskModel(task))
        try modelContext.save()
    }

    func rename(id: UUID, name: String) throws {
        guard let model = try model(id: id) else { return }
        model.name = name
        try modelContext.save()
    }

    func setComplete(id: UUID, isComplete: Bool) throws {
        guard let model = try model(id: id) else { return }
        model.isComplete = isComplete
        try modelContext.save()
    }

    // MARK: - Helpers
    private func model(id: UUID) throws -> TodoTaskModel? {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
}
