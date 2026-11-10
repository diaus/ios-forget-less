import Domain
import Foundation
import WidgetKit

/// What the widget shows from one moment on.
nonisolated struct UpcomingWidgetEntry: TimelineEntry {
    let date: Date
    let content: UpcomingWidgetContent
    let cutEnding: CutEnding
    let showsLeftOutCount: Bool
    let showsMoveArrows: Bool

    /// The settings default to their own defaults, for the entries no configuration reaches.
    init(
        date: Date,
        content: UpcomingWidgetContent,
        cutEnding: CutEnding = .empty,
        showsLeftOutCount: Bool = true,
        showsMoveArrows: Bool = true
    ) {
        self.date = date
        self.content = content
        self.cutEnding = cutEnding
        self.showsLeftOutCount = showsLeftOutCount
        self.showsMoveArrows = showsMoveArrows
    }
}
