import Data
import Domain
import FactoryKit

/// Domain use cases wired to the Data repositories, one `nonisolated var` Factory each.
extension Container {
    nonisolated var addTask: Factory<AddTask> {
        self { AddTask(repository: self.todoTaskRepository()) }
    }
}
