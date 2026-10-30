import Domain
import Foundation

/// An in-memory `TodoTaskRepository` that keeps every created Task for the test to inspect.
actor FakeTodoTaskRepository: TodoTaskRepository {
    private(set) var tasks: [TodoTask] = []

    func tasks(on day: Date) -> [TodoTask] {
        tasks.filter { $0.day == day }
    }

    /// Sends the Tasks once, then ends.
    func scheduleTasks(today: Date) -> AsyncStream<[TodoTask]> {
        let scheduleTasks = tasks.filter { $0.day >= today || ($0.completeDay ?? .distantFuture) >= today }
        return AsyncStream { continuation in
            continuation.yield(scheduleTasks)
            continuation.finish()
        }
    }

    func create(name: String, day: Date) {
        let task = TodoTask(
            id: UUID(),
            name: name,
            day: day,
            completeDay: nil,
            sortIndex: TodoTask.nextSortIndex(in: tasks(on: day))
        )
        tasks.append(task)
    }

    func rename(id: UUID, name: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].name = name
    }

    func setComplete(id: UUID, isComplete: Bool, today: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].completeDay = isComplete ? today : nil
    }
}
