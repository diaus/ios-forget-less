import Foundation

/// What the widget shows: the Tasks it lists, or a state in their place.
public enum UpcomingWidgetContent: Hashable, Sendable {
    /// No Task to list, or no store yet.
    case empty
    /// The store couldn't be read.
    case unreadable
    /// One row per Task listed, never empty. `leftOutTaskCount` counts the Overdue and Today Tasks past the rows.
    case rows([UpcomingRow], leftOutTaskCount: Int)

    /// The most rows a Lock Screen column holds.
    public static let columnRowCount = 4
    /// The most rows the Lock Screen and the small size list. The sizes with controls list every Task, as many
    /// as fit.
    public static let maxRowCount = 2 * columnRowCount

    /// The rows for `tasks`, given in the Schedule's order: the first `rowLimit` of them, or all of them when it's nil.
    /// No Task, or a `rowLimit` of 0, gives `.empty`.
    /// - Parameter listsTomorrow: Whether the widget lists Tomorrow's Tasks, which a step down from Today can reach.
    public init(tasks: [TodoTask], today: Date, listsTomorrow: Bool, rowLimit: Int? = Self.maxRowCount) {
        let rowLimit = rowLimit ?? tasks.count
        guard !tasks.isEmpty, rowLimit > 0 else {
            self = .empty
            return
        }
        // Worked out over every Task, so a row's step can name a Task past the last one listed.
        let destinations = tasks.oneStepDestinations(today: today, listsTomorrow: listsTomorrow)
        let rows = zip(tasks, destinations).map { task, destinations in
            UpcomingRow(task: task, today: today, oneStepDestinations: destinations)
        }
        self = .rows(
            Array(rows.prefix(rowLimit)),
            leftOutTaskCount: Self.leftOutTaskCount(of: rows.dropFirst(rowLimit))
        )
    }

    /// How many of `rowsLeftOut` the widget counts as left out: Tomorrow's Tasks never count.
    public static func leftOutTaskCount(of rowsLeftOut: some Sequence<UpcomingRow>) -> Int {
        rowsLeftOut.count { $0.marker != .tomorrow }
    }
}
