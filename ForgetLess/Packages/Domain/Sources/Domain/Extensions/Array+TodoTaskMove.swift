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
    /// Where each of these listed Tasks goes one step up or down, by the Schedule's step rule, when only Overdue, Today
    /// and, if `listsTomorrow`, Tomorrow are listed.
    /// - Parameter self: The listed Incomplete Tasks, in order of Day, then position within it.
    func oneStepDestinations(today: Date, listsTomorrow: Bool) -> [OneStepDestinations] {
        let schedule = Schedule(tasks: self, today: today, windowDayCount: listsTomorrow ? 2 : 1)
        return indices.map { index in
            let task = self[index]
            let stepDown = schedule.destinationOneStepDown(for: task)
            let next = index < count - 1 ? self[index + 1] : nil
            // A step to the top of a Day passes the next listed Task only while that Task is on a Day before it.
            let stepDownPassesATask = if let stepDown {
                stepDown.after != nil || next.map { $0.day < stepDown.day } == true
            } else {
                false
            }
            return OneStepDestinations(
                stepUp: schedule.destinationOneStepUp(for: task),
                stepDown: stepDown,
                stepDownPassesATask: stepDownPassesATask
            )
        }
    }
}
