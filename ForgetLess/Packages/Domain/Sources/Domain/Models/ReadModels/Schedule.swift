import Foundation

/// What the Schedule screen lists. The widget lists its first Days.
public struct Schedule: Sendable {
    /// A Day of the Schedule and its Tasks.
    public struct Day: Identifiable, Sendable {
        public let day: Date
        public let tasks: [TodoTask]
        /// Whether this Day opens a week the Day listed before it isn't in. Never true for the first Day listed.
        public let startsWeek: Bool
        /// Whether this Day opens a month the Day listed before it isn't in, or, listed first, is the month's 1st.
        public let startsMonth: Bool

        public var id: Date { day }
    }

    /// The Overdue Tasks, with those completed from it on Today, oldest Day first.
    public let overdue: [TodoTask]
    public let days: [Day]

    /// - Parameters:
    ///   - tasks: In order of Day, then position within it, as the repository sends them.
    ///   - showsComplete: Whether Complete Tasks are listed.
    ///   - keptTaskIDs: Complete Tasks listed even while Complete Tasks are hidden, so a mis-tap can be undone.
    ///   - firstWeekday: The weekday weeks start on, numbered as `Date.firstWeekday` is.
    ///   - windowDayCount: How many Days from Today on are listed, with Tasks or not. A later Day is listed only for
    ///     its Tasks.
    public init(
        tasks: [TodoTask],
        today: Date,
        showsComplete: Bool = true,
        keptTaskIDs: Set<UUID> = [],
        firstWeekday: Int = Date.firstWeekday,
        windowDayCount: Int = 100
    ) {
        let tasks = showsComplete ? tasks : tasks.filter { !$0.isComplete || keptTaskIDs.contains($0.id) }
        // A Task completed from Overdue stays there until Today rolls over, so a mis-tap can be undone.
        overdue = tasks.filter { $0.day < today && ($0.completeDay ?? .distantFuture) >= today }
        // Grouping keeps each Day's Tasks in the order given.
        let tasksByDay = Dictionary(grouping: tasks) { $0.day }
        let window = (0..<windowDayCount).map { today.addingDays($0) }
        let afterWindow = today.addingDays(windowDayCount)
        var laterDays: [Date] = []
        // The input is in Day order, so each Day's Tasks are next to each other and its first one adds it.
        for task in tasks where task.day >= afterWindow && laterDays.last != task.day {
            laterDays.append(task.day)
        }
        let listedDays = window + laterDays
        days = listedDays.indices.map { index in
            let day = listedDays[index]
            let previousDay = index > 0 ? listedDays[index - 1] : nil
            return Day(
                day: day,
                tasks: tasksByDay[day, default: []],
                startsWeek: previousDay.map { !day.isInSameWeek(as: $0, firstWeekday: firstWeekday) } ?? false,
                startsMonth: previousDay.map { !day.isInSameMonth(as: $0) } ?? day.isFirstDayOfMonth
            )
        }
    }

    // MARK: - Moving
    /// The move rule: whether `task` can be moved to `destination`.
    public func canMove(_ task: TodoTask, to destination: MoveDestination) -> Bool {
        isListed(task) && days.contains { $0.day == destination.day }
    }

    /// The move rule for a Move to the end of `day`, listed or not: whether `task` can go there.
    public func canMove(_ task: TodoTask, toDay day: Date) -> Bool {
        // The window opens on Today, and Overdue is never a destination.
        guard let today = days.first?.day, day.canBePlanned(today: today) else { return false }
        return isListed(task)
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

    /// The move rule for a drop: whether `task` can be dropped on `day` at `index` among the Tasks listed there,
    /// counted without `task`.
    public func canMove(_ task: TodoTask, droppedOn day: Date, at index: Int) -> Bool {
        canMove(task, to: destination(forDropOf: task, on: day, at: index))
    }

    /// Where `task` goes when dropped on `day` at `index` among the Tasks listed there, counted without `task`.
    public func destination(forDropOf task: TodoTask, on day: Date, at index: Int) -> MoveDestination {
        let others = days.first { $0.day == day }?.tasks.filter { $0.id != task.id } ?? []
        return MoveDestination(day: day, after: index > 0 ? others[index - 1].id : nil)
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

    /// Whether the Schedule lists `task`, in Overdue or on a Day: only a Task it lists can move.
    private func isListed(_ task: TodoTask) -> Bool {
        isOverdue(task) || position(of: task) != nil
    }
}
