import Domain
import Foundation

/// What the widget shows: the Tasks it lists, or a state in their place.
nonisolated enum UpcomingWidgetContent: Hashable {
    /// No Task to list, or no store yet.
    case empty
    /// The store couldn't be read.
    case unreadable
    /// One row per Task, never empty and never more than `maxRowCount`.
    case rows([UpcomingRow])

    static let maxRowCount = 8

    /// The rows for `tasks`, given in the Schedule's order, keeping only the first `maxRowCount`.
    init(tasks: [TodoTask], today: Date) {
        guard !tasks.isEmpty else {
            self = .empty
            return
        }
        self = .rows(tasks.prefix(Self.maxRowCount).map { UpcomingRow(task: $0, today: today) })
    }
}

extension UpcomingWidgetContent {
    /// Stands in for the user's Tasks in the widget gallery and, redacted, in the placeholder.
    nonisolated static let sample = UpcomingWidgetContent.rows([
        UpcomingRow(name: "Pay rent", marker: .overdue),
        UpcomingRow(name: "Buy oat milk", marker: nil),
        UpcomingRow(name: "Call mum", marker: nil),
    ])
}
