import Domain
import SwiftUI
import WidgetKit

/// What the widget shows, on the Lock Screen or the Home Screen.
struct UpcomingWidgetView: View {
    let content: UpcomingWidgetContent
    let cutEnding: CutEnding
    let showsLeftOutCount: Bool

    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch content {
            case .empty:
                StateSymbolView(badgeSystemName: "checkmark")
            case .unreadable:
                StateSymbolView(badgeSystemName: "exclamationmark.triangle")
            case .rows(let rows, let leftOutTaskCount):
                let leftOutTaskCountIfShown = showsLeftOutCount ? leftOutTaskCount : nil
                if family.isOnLockScreen {
                    LockScreenRowsView(rows: rows, leftOutTaskCount: leftOutTaskCountIfShown, cutEnding: cutEnding)
                } else {
                    HomeScreenRowsView(rows: rows, leftOutTaskCount: leftOutTaskCountIfShown)
                }
            }
        }
        .containerBackground(
            family.isOnLockScreen ? AnyShapeStyle(.clear) : AnyShapeStyle(.background),
            for: .widget
        )
    }
}

// One entry per kind of content: step through them in the canvas.
#Preview("Each content", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .sample)
    UpcomingWidgetEntry(date: .now, content: .empty)
    UpcomingWidgetEntry(date: .now, content: .unreadable)
}

#Preview("Home Screen, each content", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .sample)
    UpcomingWidgetEntry(date: .now, content: .empty)
    UpcomingWidgetEntry(date: .now, content: .unreadable)
}
