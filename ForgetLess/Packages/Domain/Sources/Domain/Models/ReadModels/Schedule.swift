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

    /// How long Overdue keeps a Task completed from it, so a mis-tap can be undone.
    public static let overdueHour: TimeInterval = 60 * 60

    /// The Overdue Tasks, with those completed from it within the hour, oldest Day first.
    public let overdue: [TodoTask]
    public let days: [Day]
    /// The first Day listed in History, or `nil` outside History.
    public let historyFirstDay: Date?
    private let today: Date

    /// The Overdue Tasks, without those completed from it: what a Move of all of Overdue moves.
    public var overdueIncomplete: [TodoTask] { overdue.filter { !$0.isComplete } }

    /// When the hour of the next Task kept in Overdue ends and the Schedule lists otherwise; `nil` when Overdue keeps
    /// none.
    public var nextOverdueHourEnd: Date? {
        overdue.compactMap(Self.overdueHourEnd).min()
    }

    /// - Parameters:
    ///   - tasks: In order of Day, then position within it, as the repository sends them.
    ///   - now: The moment the Schedule lists at, which ends the hour a Task completed from Overdue stays there.
    ///   - showsComplete: Whether Complete Tasks are listed.
    ///   - keptTaskIDs: Complete Tasks listed even while Complete Tasks are hidden, so a mis-tap can be undone.
    ///   - windowDayCount: How many Days from Today on are listed, with Tasks or not. A later Day is listed only for
    ///     its Tasks.
    ///   - historyFirstDay: The first Day listed in History, or `nil` to list outside History.
    public init(
        tasks: [TodoTask],
        today: Date,
        now: Date,
        showsComplete: Bool = true,
        keptTaskIDs: Set<UUID> = [],
        windowDayCount: Int = 100,
        historyFirstDay: Date? = nil
    ) {
        self.today = today
        self.historyFirstDay = historyFirstDay
        let showsHistory = historyFirstDay != nil
        let tasks = showsComplete ? tasks : tasks.filter { !$0.isComplete || keptTaskIDs.contains($0.id) }
        // History lists Overdue Tasks on their own Days.
        overdue = showsHistory ? [] : tasks.filter { task in
            guard task.day < today else { return false }
            // Measured against now, so the hour runs on past midnight.
            return Self.overdueHourEnd(of: task).map { now < $0 } ?? true
        }
        // Grouping keeps each Day's Tasks in the order given.
        let tasksByDay = Dictionary(grouping: tasks) { $0.day }
        let pastDays = historyFirstDay?.days(upTo: today) ?? []
        let afterWindow = today.addingDays(windowDayCount)
        let window = today.days(upTo: afterWindow)
        var laterDays: [Date] = []
        // The input is in Day order, so each Day's Tasks are next to each other and its first one adds it.
        for task in tasks where task.day >= afterWindow && laterDays.last != task.day {
            laterDays.append(task.day)
        }
        let listedDays = pastDays + window + laterDays
        days = listedDays.indices.map { index in
            let day = listedDays[index]
            let previousDay = index > 0 ? listedDays[index - 1] : nil
            return Day(
                day: day,
                tasks: tasksByDay[day, default: []],
                startsWeek: previousDay.map { !day.isInSameWeek(as: $0) } ?? false,
                startsMonth: previousDay.map { !day.isInSameMonth(as: $0) } ?? day.isFirstDayOfMonth
            )
        }
    }

    // MARK: - Paging History
    /// How many Days further back History lists each time the list nears its top.
    public static let historyPageDayCount = 60

    /// The History first Day that lists `day`: `historyFirstDay` when it lists `day` already, else a page before
    /// `day`, so there's room above it to scroll on back.
    public static func historyFirstDay(listing day: Date, from historyFirstDay: Date) -> Date {
        day < historyFirstDay ? day.addingDays(-historyPageDayCount) : historyFirstDay
    }

    // MARK: - Going to a Day
    /// The last Day listed on or before `day`: `day` itself when listed. `nil` when no Day before it is listed, as
    /// while History doesn't list back to it yet.
    public func listedDay(onOrBefore day: Date) -> Date? {
        days.last { $0.day <= day }?.day
    }

    // MARK: - Moving
    /// The move rule: whether `task` can be moved to `destination`.
    public func canMove(_ task: TodoTask, to destination: MoveDestination) -> Bool {
        isListed(task) && days.contains { $0.day == destination.day }
    }

    /// The move rule for a Move to the end of `day`, listed or not: whether `task` can go there.
    public func canMoveToEnd(_ task: TodoTask, of day: Date) -> Bool {
        // Outside History, Overdue is never a destination.
        day.canBeChosen(today: today, showsHistory: showsHistory) && isListed(task)
    }

    /// The move rule for a Move of the Overdue Tasks to the top of `day`: whether there are any, and they can go there.
    public func canMoveOverdueTasks(toStartOf day: Date) -> Bool {
        // Overdue is never a destination.
        day.canBePlanned(today: today) && !overdueIncomplete.isEmpty
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
        if isOverdue(task) {
            return MoveDestination(day: today, after: nil)
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
    /// When Overdue stops keeping `task`, were it completed from there; `nil` while it's Incomplete.
    private static func overdueHourEnd(of task: TodoTask) -> Date? {
        task.completeTime?.addingTimeInterval(overdueHour)
    }

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

    private var showsHistory: Bool {
        historyFirstDay != nil
    }

    /// Whether the Schedule lists `task`, in Overdue or on a Day: only a Task it lists can move.
    private func isListed(_ task: TodoTask) -> Bool {
        isOverdue(task) || position(of: task) != nil
    }
}
