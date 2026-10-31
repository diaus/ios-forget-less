import Domain
import Foundation

/// What the widget shows: the Tasks it lists, or a state in their place.
nonisolated enum UpcomingWidgetContent: Hashable {
    /// No Task to list, or no store yet.
    case empty
    /// The store couldn't be read.
    case unreadable
    /// One row per Task, never empty and never more than two columns of `columnRowCount`.
    case rows([UpcomingRow])

    /// The most rows a column holds.
    static let columnRowCount = 4

    /// The rows for `tasks`, given in the Schedule's order, keeping only as many as fit in one column, or in two when
    /// `showsTwoColumns`.
    init(tasks: [TodoTask], today: Date, showsTwoColumns: Bool) {
        guard !tasks.isEmpty else {
            self = .empty
            return
        }
        let maxRowCount = Self.columnRowCount * (showsTwoColumns ? 2 : 1)
        self = .rows(tasks.prefix(maxRowCount).map { UpcomingRow(task: $0, today: today) })
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
