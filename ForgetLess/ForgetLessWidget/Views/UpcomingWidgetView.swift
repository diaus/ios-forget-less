import SwiftUI
import WidgetKit

/// What the widget shows on the Lock Screen.
struct UpcomingWidgetView: View {
    let content: UpcomingWidgetContent

    var body: some View {
        switch content {
        case .empty:
            StateSymbolView(badgeSystemName: "checkmark")
        case .unreadable:
            StateSymbolView(badgeSystemName: "exclamationmark.triangle")
        case .rows(let rows):
            UpcomingRowsView(rows: rows)
        }
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
