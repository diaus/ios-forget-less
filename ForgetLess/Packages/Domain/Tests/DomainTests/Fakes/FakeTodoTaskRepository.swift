import Domain
import Foundation

/// An in-memory `TodoTaskRepository` that keeps every created Task for the test to inspect.
actor FakeTodoTaskRepository: TodoTaskRepository {
    private(set) var tasks: [TodoTask] = []

    func tasks(on day: Date) -> [TodoTask] {
        tasks.filter { $0.day == day }
    }

    func tasks(onOrAfter day: Date) -> [TodoTask] {
        tasks.filter { $0.day >= day }
    }

    func create(name: String, day: Date) {
        let task = TodoTask(
            id: UUID(),
            name: name,
            day: day,
            isComplete: false,
            sortIndex: TodoTask.nextSortIndex(in: tasks(on: day))
        )
        tasks.append(task)
    }

    func rename(id: UUID, name: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].name = name
    }

    func setComplete(id: UUID, isComplete: Bool) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isComplete = isComplete
    }
}
