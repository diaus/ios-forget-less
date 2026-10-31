import AppIntents
import WidgetKit

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// The widget's settings: whether it lists Overdue Tasks and Tomorrow's Tasks besides Today's, and how it lays them
/// out.
struct UpcomingWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "widget.title"

    @Parameter(title: "widget.showOverdueTasks", default: true)
    var showsOverdueTasks: Bool

    @Parameter(title: "widget.showTomorrowTasks", default: true)
    var showsTomorrowTasks: Bool

    @Parameter(title: "widget.showTwoColumns", default: false)
    var showsTwoColumns: Bool

    @Parameter(title: "widget.cutEnding", default: .empty)
    var cutEnding: CutEnding

    // The truncation mark applies only to two columns, so the settings sheet hides it while they're off.
    static var parameterSummary: some ParameterSummary {
        When(\.$showsTwoColumns, .equalTo, true) {
            Summary {
                \.$showsOverdueTasks
                \.$showsTomorrowTasks
                \.$showsTwoColumns
                \.$cutEnding
            }
        } otherwise: {
            Summary {
                \.$showsOverdueTasks
                \.$showsTomorrowTasks
                \.$showsTwoColumns
            }
        }
    }
}

// swiftlint:enable catalog_key_literal
