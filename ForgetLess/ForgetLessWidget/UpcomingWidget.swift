import Domain
import SwiftUI
import WidgetKit

/// The Lock Screen and Home Screen widget: Overdue and Today's Incomplete Tasks, and Tomorrow's when its setting is on.
/// The sizes with controls also make them Complete and Move them.
struct UpcomingWidget: Widget {
    nonisolated static let kind = "UpcomingWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: UpcomingWidgetIntent.self,
            provider: UpcomingTimelineProvider()
        ) { entry in
            UpcomingWidgetView(
                content: entry.content,
                cutEnding: entry.cutEnding,
                showsLeftOutCount: entry.showsLeftOutCount,
                showsMoveArrows: entry.showsMoveArrows
            )
        }
        .configurationDisplayName(Text(.widgetTitle))
        .description(Text(.widgetDescription))
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium, .systemLarge])
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

#Preview("Home Screen, gallery sample", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .sample)
}

#Preview("Home Screen, Overdue on, Tomorrow on", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: true)
}

#Preview("Medium, gallery sample", as: .systemMedium) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .sample)
}

#Preview("Medium, Overdue on, Tomorrow on", as: .systemMedium) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: true, rowLimit: nil)
}

#Preview("Medium, 8 Tasks, as many as fit", as: .systemMedium) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 8, rowLimit: nil)
}

#Preview("Medium, 20 Tasks, as many as fit", as: .systemMedium) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 20, rowLimit: nil)
}

#Preview("Medium, each content", as: .systemMedium) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .empty)
    UpcomingWidgetEntry(date: .now, content: .unreadable)
}

#Preview("Large, gallery sample", as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .sample)
}

#Preview("Large, Overdue on, Tomorrow on", as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: true, rowLimit: nil)
}

#Preview("Large, 8 Tasks", as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 8, rowLimit: nil)
}

#Preview("Large, 30 Tasks, as many as fit", as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 30, rowLimit: nil)
}

#Preview("Large, each content", as: .systemLarge) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .empty)
    UpcomingWidgetEntry(date: .now, content: .unreadable)
}
