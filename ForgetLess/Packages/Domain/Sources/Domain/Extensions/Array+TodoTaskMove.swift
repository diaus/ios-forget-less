import Foundation

public extension Array where Element == TodoTask {
    /// These Tasks once the Task with `id` is moved to `destination`, as the repository stores them after the move.
    /// - Parameter self: In order of Day, then position within it, which the result keeps.
    func movingTask(id: UUID, to destination: MoveDestination) -> [TodoTask] {
        guard let moved = first(where: { $0.id == id }) else { return self }
        let tasksOfDay = TodoTask.order(afterMoving: moved, to: destination, in: filter { $0.day == destination.day })
        let otherDays = filter { $0.day != destination.day && $0.id != id }
        return (otherDays + tasksOfDay).sorted { ($0.day, $0.sortIndex) < ($1.day, $1.sortIndex) }
    }
}
