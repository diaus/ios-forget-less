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

    /// These Tasks once the Tasks with `ids` are moved, in that order, to the top of `day`, as the repository stores
    /// them after the move. IDs with no Task are skipped.
    /// - Parameter self: In order of Day, then position within it, which the result keeps.
    func movingTasks(ids: [UUID], toStartOf day: Date) -> [TodoTask] {
        let moved = ids.compactMap { id in first { $0.id == id } }
        // The repository then saves nothing, so `day` keeps its numbering.
        guard !moved.isEmpty else { return self }
        let movedIDs = Set(moved.map(\.id))
        let tasksOfDay = TodoTask.order(afterMoving: moved, toStartOf: day, in: filter { $0.day == day })
        let otherDays = filter { $0.day != day && !movedIDs.contains($0.id) }
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
    /// and, if `listsTomorrow`, Tomorrow are listed. A Complete Task, listed for the widget's Grace Period, goes
    /// nowhere, and the other Tasks' steps pass over it.
    /// - Parameter self: The listed Tasks, in order of Day, then position within it.
    func oneStepDestinations(today: Date, listsTomorrow: Bool) -> [OneStepDestinations] {
        // Complete Tasks are hidden, so any moment the Schedule lists at gives the same steps.
        let schedule = Schedule(
            tasks: self, today: today, now: today, showsComplete: false, windowDayCount: listsTomorrow ? 2 : 1
        )
        return indices.map { index in
            let task = self[index]
            guard !task.isComplete else {
                return OneStepDestinations(stepUp: nil, stepDown: nil, stepDownPassesATask: false)
            }
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
