import Domain
import Foundation

/// What the widget shows: the Tasks it lists, or a state in their place.
nonisolated enum UpcomingWidgetContent: Hashable {
    /// No Task to list, or no store yet.
    case empty
    /// The store couldn't be read.
    case unreadable
    /// One row per Task, never empty.
    case rows([UpcomingRow])

    /// The most rows a Lock Screen column holds.
    static let columnRowCount = 4
    /// The most rows the Lock Screen and the small size list. The large size lists every Task, as many as fit.
    static let maxRowCount = 2 * columnRowCount

    /// The rows for `tasks`, given in the Schedule's order: the first `rowLimit` of them, or all of them when it's nil.
    /// No Task, or a `rowLimit` of 0, gives `.empty`.
    /// - Parameter listsTomorrow: Whether the widget lists Tomorrow's Tasks, which a step down from Today can reach.
    init(tasks: [TodoTask], today: Date, listsTomorrow: Bool, rowLimit: Int? = Self.maxRowCount) {
        let rowLimit = rowLimit ?? tasks.count
        guard !tasks.isEmpty, rowLimit > 0 else {
            self = .empty
            return
        }
        // Worked out over every Task, so a row's step can name a Task past the last one listed.
        let destinations = tasks.oneStepDestinations(today: today, listsTomorrow: listsTomorrow)
        self = .rows(zip(tasks, destinations).prefix(rowLimit).map { task, destinations in
            UpcomingRow(task: task, today: today, oneStepDestinations: destinations)
        })
    }
}

extension UpcomingWidgetContent {
    /// Stands in for the user's Tasks in the widget gallery and, redacted, in the placeholder.
    nonisolated static var sample: UpcomingWidgetContent {
        // Computed, so a language change shows on the next gallery or placeholder request.
        let today = Date.today
        let names: [(LocalizedStringResource, Date)] = [
            (.widgetSamplePayRent, today),
            (.widgetSampleBuyOatMilk, today),
            (.widgetSampleCallMum, today.addingDays(1)),
        ]
        let tasks = names.enumerated().map { index, sample in
            TodoTask(id: UUID(), name: String(localized: sample.0), day: sample.1, completeDay: nil, sortIndex: index)
        }
        return UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true)
    }
}
