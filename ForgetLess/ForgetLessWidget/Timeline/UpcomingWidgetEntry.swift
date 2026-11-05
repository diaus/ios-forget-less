import Domain
import Foundation
import WidgetKit

/// What the widget shows from one moment on.
nonisolated struct UpcomingWidgetEntry: TimelineEntry {
    let date: Date
    let content: UpcomingWidgetContent
    let cutEnding: CutEnding

    /// `cutEnding` defaults to the setting's own default, for the entries no configuration reaches.
    init(date: Date, content: UpcomingWidgetContent, cutEnding: CutEnding = .empty) {
        self.date = date
        self.content = content
        self.cutEnding = cutEnding
    }
}
