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

    /// Where the Task with `id` goes to be last on `day`, after every other Task there, Complete or not.
    /// - Parameter self: In order of Day, then position within it.
    func destinationAtEnd(of day: Date, forTaskWithID id: UUID) -> MoveDestination {
        MoveDestination(day: day, after: last { $0.day == day && $0.id != id }?.id)
    }
}

public extension Array where Element == TodoTask {
    /// The step rule: where each of these listed Tasks goes one step up or down. A step stays within the Task's Day,
    /// except across the border of Today and Tomorrow, which a step down crosses only while Tomorrow is listed. Nothing
    /// steps into or out of Overdue.
    /// - Parameter self: The listed Incomplete Tasks, in order of Day, then position within it.
    func oneStepDestinations(today: Date, listsTomorrow: Bool) -> [OneStepDestinations] {
        let tomorrow = today.addingDays(1)
        return indices.map { index in
            let task = self[index]
            let previous = index > 0 ? self[index - 1] : nil
            let twoAbove = index > 1 ? self[index - 2] : nil
            let next = index < count - 1 ? self[index + 1] : nil
            let destinationOneStepUp: MoveDestination? = if let previous, previous.day == task.day {
                // Right after the Task listed above `previous`, which puts it right before `previous`.
                MoveDestination(day: task.day, after: twoAbove?.day == task.day ? twoAbove?.id : nil)
            } else if task.day == tomorrow {
                MoveDestination(day: today, after: previous?.day == today ? previous?.id : nil)
            } else {
                nil
            }
            let crossesDay = task.day == today && listsTomorrow && next?.day != today
            let destinationOneStepDown: MoveDestination? = if let next, next.day == task.day {
                MoveDestination(day: task.day, after: next.id)
            } else if crossesDay {
                MoveDestination(day: tomorrow, after: nil)
            } else {
                nil
            }
            // A step to the top of Tomorrow takes the place the Task leaves, so it stays shown.
            return OneStepDestinations(
                destinationOneStepUp: destinationOneStepUp,
                destinationOneStepDown: destinationOneStepDown,
                destinationOneStepDownFromLastShownRow: crossesDay ? destinationOneStepDown : nil
            )
        }
    }
}
