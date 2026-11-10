import Domain
import Foundation

/// An in-memory `TodoTaskRepository` that keeps every created Task for the test to inspect.
actor FakeTodoTaskRepository: TodoTaskRepository {
    private(set) var tasks: [TodoTask] = []

    /// Sends the Tasks once, then ends.
    func scheduleTasks(today: Date, historyFirstDay: Date?) -> AsyncStream<[TodoTask]> {
        let scheduleTasks = tasks.filter { task in
            if let historyFirstDay { return task.day >= historyFirstDay }
            let completedSince = Date.now.addingTimeInterval(-Schedule.overdueHour)
            return task.day >= today || (task.completeTime ?? .distantFuture) >= completedSince
        }
        return AsyncStream { continuation in
            continuation.yield(scheduleTasks)
            continuation.finish()
        }
    }

    func incompleteTasks(from firstDay: Date?, through lastDay: Date) -> [TodoTask] {
        tasks.filter { !$0.isComplete && $0.day >= (firstDay ?? .distantPast) && $0.day <= lastDay }
    }

    func create(name: String, day: Date) {
        let task = TodoTask(
            id: UUID(),
            name: name,
            day: day,
            completeTime: nil,
            sortIndex: TodoTask.nextSortIndex(in: tasks.filter { $0.day == day })
        )
        tasks.append(task)
    }

    func rename(id: UUID, name: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].name = name
    }

    func setComplete(id: UUID, isComplete: Bool, now: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].completeTime = isComplete ? now : nil
    }

    func move(id: UUID, to destination: MoveDestination) {
        guard let task = tasks.first(where: { $0.id == id }) else { return }
        let order = TodoTask.order(afterMoving: task, to: destination, in: tasks.filter { $0.day == destination.day })
        tasks.removeAll { $0.day == destination.day || $0.id == id }
        for (sortIndex, var task) in order.enumerated() {
            task.day = destination.day
            task.sortIndex = sortIndex
            tasks.append(task)
        }
    }

    func move(ids: [UUID], toStartOf day: Date) {
        tasks = tasks.movingTasks(ids: ids, toStartOf: day)
    }

    func delete(id: UUID) {
        tasks.removeAll { $0.id == id }
    }
}
