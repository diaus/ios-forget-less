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
        let now = Date.now
        let repository = Result { try AppGroupStore.repository(writable: false) }
        let gracePeriod = Self.gracePeriod(for: configuration, family: context.family)
        let tasks = await listedTasks(at: now, gracePeriod: gracePeriod, for: configuration, in: repository)
        return entry(at: now, listing: tasks, for: configuration, family: context.family)
    }

    /// One entry for now, one for each moment a Task kept for the Grace Period leaves, and one at the next rollover,
    /// so the widget reaches the next Day without the app. WidgetKit asks again after the last entry, or after
    /// `retryDelay` when the store couldn't be read.
    func timeline(for configuration: UpcomingWidgetIntent, in context: Context) async -> Timeline<UpcomingWidgetEntry> {
        let now = Date.now
        let rollover = Date.nextRollover(after: now)
        let repository = Result { try AppGroupStore.repository(writable: false) }
        let gracePeriod = Self.gracePeriod(for: configuration, family: context.family)
        let tasksNow = await listedTasks(at: now, gracePeriod: gracePeriod, for: configuration, in: repository)
        // The rollover entry keeps no Task, so a Task that would leave after it needs no entry of its own.
        let gracePeriodEnds = ((try? tasksNow.get()) ?? []).gracePeriodEnds(lasting: gracePeriod, before: rollover)
        let entryNow = entry(at: now, listing: tasksNow, for: configuration, family: context.family)
        let laterEntries = await entries(
            at: gracePeriodEnds, gracePeriod: gracePeriod, for: configuration, family: context.family, in: repository
        ) + entries(at: [rollover], gracePeriod: 0, for: configuration, family: context.family, in: repository)
        let timelineEntries = [entryNow] + laterEntries
        let policy: TimelineReloadPolicy = timelineEntries.contains { $0.content == .unreadable }
            ? .after(now.addingTimeInterval(Self.retryDelay))
            : .atEnd
        return Timeline(entries: timelineEntries, policy: policy)
    }

    // MARK: - Helpers
    /// How many rows the content holds: nil for every Task.
    private static func rowLimit(for family: WidgetFamily, showsTwoColumns: Bool) -> Int? {
        // The sizes with controls list as many as fit, which only their view can tell.
        guard !family.hasControls else { return nil }
        // The Home Screen never shows two columns, so the setting is hidden there and doesn't apply.
        return family.isOnLockScreen && !showsTwoColumns
            ? UpcomingWidgetContent.columnRowCount
            : UpcomingWidgetContent.maxRowCount
    }

    /// How long the widget keeps a Task made Complete: only the sizes with controls, which can undo it, keep one.
    private static func gracePeriod(for configuration: UpcomingWidgetIntent, family: WidgetFamily) -> TimeInterval {
        family.hasControls ? (configuration.gracePeriod ?? .standard).duration : 0
    }

    /// The Tasks the widget lists at `moment`, on its Today, with those made Complete less than `gracePeriod` before
    /// it: nil while the app hasn't created the store.
    private func listedTasks(
        at moment: Date,
        gracePeriod: TimeInterval,
        for configuration: UpcomingWidgetIntent,
        in repository: Result<(any TodoTaskRepository)?, any Error>
    ) async -> Result<[TodoTask]?, any Error> {
        let today = Date.today(at: moment)
        do {
            return .success(try await repository.get()?.upcomingTasks(
                from: configuration.showsOverdueTasks ? nil : today,
                through: configuration.showsTomorrowTasks ? today.addingDays(1) : today,
                completedWithin: gracePeriod,
                before: moment
            ))
        } catch {
            return .failure(error)
        }
    }

    /// One entry for each of `moments`, listing the Tasks the widget lists then.
    private func entries(
        at moments: [Date],
        gracePeriod: TimeInterval,
        for configuration: UpcomingWidgetIntent,
        family: WidgetFamily,
        in repository: Result<(any TodoTaskRepository)?, any Error>
    ) async -> [UpcomingWidgetEntry] {
        var entries: [UpcomingWidgetEntry] = []
        for moment in moments {
            let tasks = await listedTasks(at: moment, gracePeriod: gracePeriod, for: configuration, in: repository)
            entries.append(entry(at: moment, listing: tasks, for: configuration, family: family))
        }
        return entries
    }

    /// The entry for the Today of `moment`, listing `tasks`.
    private func entry(
        at moment: Date,
        listing tasks: Result<[TodoTask]?, any Error>,
        for configuration: UpcomingWidgetIntent,
        family: WidgetFamily
    ) -> UpcomingWidgetEntry {
        let content: UpcomingWidgetContent = switch tasks {
        case .success(let tasks?):
            UpcomingWidgetContent(
                tasks: tasks,
                today: Date.today(at: moment),
                listsTomorrow: configuration.showsTomorrowTasks,
                rowLimit: Self.rowLimit(for: family, showsTwoColumns: configuration.showsTwoColumns)
            )
        case .success(nil): .empty
        case .failure: .unreadable
        }
        return UpcomingWidgetEntry(
            date: moment,
            content: content,
            cutEnding: configuration.cutEnding,
            showsLeftOutCount: configuration.showsLeftOutCount,
            showsMoveArrows: configuration.showsMoveArrows
        )
    }
}
