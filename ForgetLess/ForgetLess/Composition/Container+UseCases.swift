import Data
import Domain
import FactoryKit

/// Factories for the Domain use cases.
extension Container {
    nonisolated var addTask: Factory<AddTask> {
        self { AddTask(repository: self.todoTaskRepository()) }
    }
}
