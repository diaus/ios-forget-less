import Domain
import FactoryKit
import SwiftData

public extension Container {
    /// The single `ModelContainer`: the App Group store, or an in-memory one in SwiftUI previews.
    var modelContainer: Factory<ModelContainer> {
        self { Self.makeModelContainer(ForgetLessModelContainer.makeInAppGroup) }
            .onPreview { Self.makeModelContainer(ForgetLessModelContainer.makeInMemory) }
            .singleton
    }

    /// Runs after every successful save. Does nothing until the app overrides it, so Data stays free of WidgetKit
    /// (ADR 0003). An override registered at any time before a save applies to that save.
    var afterStoreSave: Factory<@Sendable () -> Void> {
        self { {} }
    }

    /// The Task store.
    var todoTaskRepository: Factory<any TodoTaskRepository> {
        self {
            // Resolved at each save, not once here, so the app's override applies whenever it registers.
            TodoTaskRepositoryLive(modelContainer: self.modelContainer(), afterStoreSave: { self.afterStoreSave()() })
        }
        .singleton
    }

    // MARK: - Helpers
    private static func makeModelContainer(_ make: () throws -> ModelContainer) -> ModelContainer {
        do {
            return try make()
        } catch {
            fatalError("Could not create the ModelContainer: \(error)")
        }
    }
}
