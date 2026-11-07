import AppIntents
import WidgetKit

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// The widget's settings: whether it lists Overdue Tasks and Tomorrow's Tasks besides Today's, whether it counts the
/// Tasks it leaves out, and how it lays them out.
struct UpcomingWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "widget.title"

    @Parameter(title: "widget.showOverdueTasks", default: true)
    var showsOverdueTasks: Bool

    @Parameter(title: "widget.showTomorrowTasks", default: true)
    var showsTomorrowTasks: Bool

    @Parameter(title: "widget.showLeftOutCount", default: true)
    var showsLeftOutCount: Bool

    @Parameter(title: "widget.showTwoColumns", default: false)
    var showsTwoColumns: Bool

    @Parameter(title: "widget.cutEnding", default: .empty)
    var cutEnding: CutEnding

    // The Home Screen never shows two columns, so its sheet hides both layout settings. On the Lock Screen, the
    // cut ending applies only to two columns, so the sheet hides it while they're off.
    static var parameterSummary: some ParameterSummary {
        When(widgetFamily: .equalTo, .accessoryRectangular) {
            When(\.$showsTwoColumns, .equalTo, true) {
                Summary {
                    \.$showsOverdueTasks
                    \.$showsTomorrowTasks
                    \.$showsLeftOutCount
                    \.$showsTwoColumns
                    \.$cutEnding
                }
            } otherwise: {
                Summary {
                    \.$showsOverdueTasks
                    \.$showsTomorrowTasks
                    \.$showsLeftOutCount
                    \.$showsTwoColumns
                }
            }
        } otherwise: {
            Summary {
                \.$showsOverdueTasks
                \.$showsTomorrowTasks
                \.$showsLeftOutCount
            }
        }
    }
}

// swiftlint:enable catalog_key_literal
