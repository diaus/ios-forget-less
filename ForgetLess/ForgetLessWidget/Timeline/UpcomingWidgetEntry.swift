import Foundation
import WidgetKit

/// What the widget shows from one moment on.
nonisolated struct UpcomingWidgetEntry: TimelineEntry {
    let date: Date
    let content: UpcomingWidgetContent
}
