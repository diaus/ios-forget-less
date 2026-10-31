import Domain
import FactoryKit
import SwiftData

public extension Container {
    /// The single `ModelContainer`: on disk, or in memory in SwiftUI previews.
    var modelContainer: Factory<ModelContainer> {
        self { Self.makeModelContainer(inMemory: false) }
            .onPreview { Self.makeModelContainer(inMemory: true) }
            .singleton
    }

    /// The Task store.
    var todoTaskRepository: Factory<any TodoTaskRepository> {
        self { TodoTaskRepositoryLive(modelContainer: self.modelContainer()) }
            .singleton
    }

    // MARK: - Helpers
    private static func makeModelContainer(inMemory: Bool) -> ModelContainer {
        do {
            return try ForgetLessModelContainer.make(inMemory: inMemory)
        } catch {
            fatalError("Could not create the ModelContainer: \(error)")
        }
    }
}
