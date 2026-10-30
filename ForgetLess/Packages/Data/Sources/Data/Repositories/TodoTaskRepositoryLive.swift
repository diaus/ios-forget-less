import Domain
import Foundation
import SwiftData

/// The SwiftData `TodoTaskRepository`. Stores each Day as given, 00:00 GMT (ADR 0001).
actor TodoTaskRepositoryLive: TodoTaskRepository, ModelActor {
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.modelContainer = modelContainer
    }

    func tasks(on day: Date) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day == day })
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func tasks(onOrAfter day: Date) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day >= day })
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func create(_ task: TodoTask) throws {
        modelContext.insert(TodoTaskModel(task))
        try modelContext.save()
    }

    func setComplete(id: UUID, isComplete: Bool) throws {
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.id == id })
        guard let model = try modelContext.fetch(descriptor).first else { return }
        model.isComplete = isComplete
        try modelContext.save()
    }
}
