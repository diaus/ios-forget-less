import Domain
import Foundation

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
            TodoTask(id: UUID(), name: String(localized: sample.0), day: sample.1, completeTime: nil, sortIndex: index)
        }
        return UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true)
    }
}
