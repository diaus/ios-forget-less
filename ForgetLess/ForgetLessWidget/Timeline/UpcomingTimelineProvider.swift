import Data
import Domain
import Foundation
import WidgetKit

/// Builds the widget's entries from the App Group store the app writes (ADR 0003).
nonisolated struct UpcomingTimelineProvider: AppIntentTimelineProvider {
    /// How long a widget whose store couldn't be read waits before WidgetKit asks again.
    private static let retryDelay: TimeInterval = 15 * 60

    // MARK: - AppIntentTimelineProvider
    func placeholder(in context: Context) -> UpcomingWidgetEntry {
        UpcomingWidgetEntry(date: .now, content: .sample)
    }

    func snapshot(for configuration: UpcomingWidgetIntent, in context: Context) async -> UpcomingWidgetEntry {
        guard !context.isPreview else { return UpcomingWidgetEntry(date: .now, content: .sample) }
        return await entry(at: .now, for: configuration, in: Result { try TodoTaskReader.repository() })
    }

    /// One entry for now and one at the next rollover, so the widget reaches the next Day without the app. WidgetKit
    /// asks again after the last entry, or after `retryDelay` when the store couldn't be read.
    func timeline(for configuration: UpcomingWidgetIntent, in context: Context) async -> Timeline<UpcomingWidgetEntry> {
        let now = Date.now
        let repository = Result { try TodoTaskReader.repository() }
        var entries: [UpcomingWidgetEntry] = []
        for moment in [now, Date.nextRollover(after: now)] {
            entries.append(await entry(at: moment, for: configuration, in: repository))
        }
        let policy: TimelineReloadPolicy = entries.contains { $0.content == .unreadable }
            ? .after(now.addingTimeInterval(Self.retryDelay))
            : .atEnd
        return Timeline(entries: entries, policy: policy)
    }

    // MARK: - Helpers
    /// The entry for the Today of `moment`. `repository` is nil while the app hasn't created the store.
    private func entry(
        at moment: Date,
        for configuration: UpcomingWidgetIntent,
        in repository: Result<(any TodoTaskRepository)?, any Error>
    ) async -> UpcomingWidgetEntry {
        let today = Date.today(at: moment)
        let content: UpcomingWidgetContent
        do {
            if let repository = try repository.get() {
                let tasks = try await repository.incompleteTasks(
                    from: configuration.showsOverdueTasks ? nil : today,
                    through: configuration.showsTomorrowTasks ? today.addingDays(1) : today
                )
                content = UpcomingWidgetContent(tasks: tasks, today: today)
            } else {
                content = .empty
            }
        } catch {
            content = .unreadable
        }
        return UpcomingWidgetEntry(date: moment, content: content)
    }
}
