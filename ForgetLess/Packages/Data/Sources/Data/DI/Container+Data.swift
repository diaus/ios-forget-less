import Domain
import FactoryKit
import SwiftData

public extension Container {
    /// The single on-disk `ModelContainer`.
    var modelContainer: Factory<ModelContainer> {
        self {
            do {
                return try ForgetLessModelContainer.make(inMemory: false)
            } catch {
                fatalError("Could not create the ModelContainer: \(error)")
            }
        }
        .singleton
    }

    /// The Task store, in the device's calendar and time zone.
    var todoTaskRepository: Factory<any TodoTaskRepository> {
        self { TodoTaskRepositoryLive(modelContainer: self.modelContainer()) }
            .singleton
    }
}
