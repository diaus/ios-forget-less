import Foundation

/// What the Schedule screen lists.
public struct Schedule: Sendable {
    /// A Day of the Schedule and its Tasks.
    public struct Day: Identifiable, Sendable {
        public let day: Date
        public let tasks: [TodoTask]

        public var id: Date { day }
    }

    /// The Overdue Tasks, with those completed from it on Today, oldest Day first.
    public let overdue: [TodoTask]
    public let days: [Day]

    /// How many Days the window holds, Today included.
    private static let windowDayCount = 100

    /// - Parameters:
    ///   - tasks: In order of Day, then position within it, as the repository sends them.
    ///   - showsComplete: Whether Complete Tasks are listed.
    ///   - keptTaskIDs: Complete Tasks listed even while Complete Tasks are hidden, so a mis-tap can be undone.
    public init(tasks: [TodoTask], today: Date, showsComplete: Bool = true, keptTaskIDs: Set<UUID> = []) {
        let tasks = showsComplete ? tasks : tasks.filter { !$0.isComplete || keptTaskIDs.contains($0.id) }
        // A Task completed from Overdue stays there until Today rolls over, so a mis-tap can be undone.
        overdue = tasks.filter { $0.day < today && ($0.completeDay ?? .distantFuture) >= today }
        // Grouping keeps each Day's Tasks in the order given.
        let tasksByDay = Dictionary(grouping: tasks) { $0.day }
        let window = (0..<Self.windowDayCount).map { today.addingDays($0) }
        let afterWindow = today.addingDays(Self.windowDayCount)
        var laterDays: [Date] = []
        // The input is in Day order, so each Day's Tasks are next to each other and its first one adds it.
        for task in tasks where task.day >= afterWindow && laterDays.last != task.day {
            laterDays.append(task.day)
        }
        days = (window + laterDays).map { day in Day(day: day, tasks: tasksByDay[day, default: []]) }
    }

    // MARK: - Moving
    /// The move rule: whether `task` can be moved to `destination`.
    public func canMove(_ task: TodoTask, to destination: MoveDestination) -> Bool {
        (isOverdue(task) || position(of: task) != nil) && days.contains { $0.day == destination.day }
    }

    /// Where `task` goes one step up among the Tasks listed, or `nil` when there's none.
    public func destinationOneStepUp(for task: TodoTask) -> MoveDestination? {
        guard let (dayIndex, taskIndex) = position(of: task) else { return nil }
        let day = days[dayIndex]
        if taskIndex > 0 {
            return MoveDestination(day: day.day, after: taskIndex > 1 ? day.tasks[taskIndex - 2].id : nil)
        }
        guard dayIndex > 0 else { return nil }
        let previousDay = days[dayIndex - 1]
        return MoveDestination(day: previousDay.day, after: previousDay.tasks.last?.id)
    }

    /// Where `task` goes one step down among the Tasks listed, or `nil` when there's none.
    public func destinationOneStepDown(for task: TodoTask) -> MoveDestination? {
        // Overdue is never a destination, so an Overdue Task's next stop is the top of Today.
        if isOverdue(task), let today = days.first {
            return MoveDestination(day: today.day, after: nil)
        }
        guard let (dayIndex, taskIndex) = position(of: task) else { return nil }
        let day = days[dayIndex]
        if taskIndex < day.tasks.count - 1 {
            return MoveDestination(day: day.day, after: day.tasks[taskIndex + 1].id)
        }
        guard dayIndex < days.count - 1 else { return nil }
        return MoveDestination(day: days[dayIndex + 1].day, after: nil)
    }

    // MARK: - Helpers
    private func position(of task: TodoTask) -> (dayIndex: Int, taskIndex: Int)? {
        for (dayIndex, day) in days.enumerated() {
            if let taskIndex = day.tasks.firstIndex(where: { $0.id == task.id }) {
                return (dayIndex, taskIndex)
            }
        }
        return nil
    }

    private func isOverdue(_ task: TodoTask) -> Bool {
        overdue.contains { $0.id == task.id }
    }
}
