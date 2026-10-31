import AppIntents
import WidgetKit

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// The widget's settings: whether it lists Overdue Tasks and Tomorrow's Tasks besides Today's.
struct UpcomingWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "widget.title"

    @Parameter(title: "widget.showOverdueTasks", default: true)
    var showsOverdueTasks: Bool

    @Parameter(title: "widget.showTomorrowTasks", default: false)
    var showsTomorrowTasks: Bool
}

// swiftlint:enable catalog_key_literal
