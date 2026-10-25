import Domain
import Foundation

/// An in-memory `TodoTaskRepository` that keeps every created Task for the test to inspect.
actor FakeTodoTaskRepository: TodoTaskRepository {
    private(set) var tasks: [TodoTask]

    init(tasks: [TodoTask] = []) {
        self.tasks = tasks
    }

    func tasks(on day: Date) -> [TodoTask] {
        tasks.filter { $0.day == day }
    }

    func tasks(onOrAfter day: Date) -> [TodoTask] {
        tasks.filter { $0.day >= day }
    }

    func create(_ task: TodoTask) {
        tasks.append(task)
    }
}
