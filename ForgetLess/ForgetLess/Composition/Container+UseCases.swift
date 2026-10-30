import Data
import Domain
import FactoryKit

/// Factories for the Domain use cases.
extension Container {
    nonisolated var addTask: Factory<AddTask> {
        self { AddTask(repository: self.todoTaskRepository()) }
    }

    nonisolated var renameTask: Factory<RenameTask> {
        self { RenameTask(repository: self.todoTaskRepository()) }
    }
}
