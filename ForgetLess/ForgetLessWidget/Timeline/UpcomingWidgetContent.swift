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

    /// The most rows a Lock Screen column holds.
    static let columnRowCount = 4
    /// The most rows the widget lists.
    static let maxRowCount = 2 * columnRowCount

    /// The rows for `tasks`, given in the Schedule's order: the first `rowLimit` of them, which must be at most
    /// `maxRowCount`. No Task, or a `rowLimit` of 0, gives `.empty`.
    init(tasks: [TodoTask], today: Date, rowLimit: Int = Self.maxRowCount) {
        guard !tasks.isEmpty, rowLimit > 0 else {
            self = .empty
            return
        }
        self = .rows(tasks.prefix(rowLimit).map { UpcomingRow(task: $0, today: today) })
    }
}

extension UpcomingWidgetContent {
    /// Stands in for the user's Tasks in the widget gallery and, redacted, in the placeholder.
    nonisolated static var sample: UpcomingWidgetContent {
        // Computed, so a language change shows on the next gallery or placeholder request.
        .rows([
            UpcomingRow(name: String(localized: .widgetSamplePayRent), marker: nil),
            UpcomingRow(name: String(localized: .widgetSampleBuyOatMilk), marker: nil),
            UpcomingRow(name: String(localized: .widgetSampleCallMum), marker: .tomorrow),
        ])
    }
}
