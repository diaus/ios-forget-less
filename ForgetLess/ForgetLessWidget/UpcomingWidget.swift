import SwiftUI
import WidgetKit

/// The Lock Screen widget: Overdue and Today's Incomplete Tasks, and Tomorrow's when its setting is on.
struct UpcomingWidget: Widget {
    nonisolated static let kind = "UpcomingWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: UpcomingWidgetIntent.self,
            provider: UpcomingTimelineProvider()
        ) { entry in
            UpcomingWidgetView(content: entry.content)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName(Text(.widgetTitle))
        .description(Text(.widgetDescription))
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview("Gallery sample", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .sample)
}

#Preview("Overdue on, Tomorrow off", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: false)
}

#Preview("Overdue off, Tomorrow off", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: false, showsTomorrowTasks: false)
}

#Preview("Overdue on, Tomorrow on", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: true)
}

#Preview("Overdue off, Tomorrow on", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: false, showsTomorrowTasks: true)
}
