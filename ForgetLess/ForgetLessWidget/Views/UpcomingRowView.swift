import Domain
import SwiftUI
import UIKit
import Utils
import WidgetKit

/// One Task the widget lists.
struct UpcomingRowView: View {
    let row: UpcomingRow
    let font: UIFont
    /// The width the widget cuts the row to itself; nil leaves the cut to the system.
    let cutWidth: CGFloat?
    /// What ends a name the widget cuts itself.
    let cutEnding: CutEnding

    @Environment(\.widgetFamily) private var family

    // MARK: - Body
    var body: some View {
        HStack(spacing: markerSpacing) {
            if let marker {
                let markerText = Text(verbatim: marker).font(Font(markerFont))
                // The Lock Screen renders in one vibrant tint, so only the Home Screen colours the "!". Any other
                // marker takes the row's own style.
                if row.marker == .overdue && !family.isOnLockScreen {
                    markerText.foregroundStyle(Color(.overdueDay)).fixedSize()
                } else {
                    markerText.fixedSize()
                }
            }
            if let cutWidth {
                let nameWidth = cutWidth - markerWidth - markerSpacing
                let name = row.name.cut(toFit: nameWidth, ending: cutEnding.text) { Self.width(of: $0, font: font) }
                Text(verbatim: name)
                    .font(Font(font))
                    // Already cut to fit, so the system never adds its own "…".
                    .fixedSize()
            } else {
                Text(verbatim: row.name)
                    .font(Font(font))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(rowStyle)
        // Takes the accent tint in the tinted and clear looks, which drop the "!"'s own colour.
        .widgetAccentable(row.marker == .overdue)
    }

    // MARK: - Helpers
    private var rowStyle: HierarchicalShapeStyle {
        row.marker == .tomorrow ? .secondary : .primary
    }

    // Width is scarce on the Lock Screen, so only the Home Screen puts a space after the marker.
    private var markerSpacing: CGFloat {
        marker != nil && !family.isOnLockScreen ? Self.width(of: " ", font: font) : 0
    }

    private var marker: String? {
        switch row.marker {
        case .overdue: "!"
        case .tomorrow: "→"
        case nil: nil
        }
    }

    private var markerFont: UIFont {
        UIFont.boldSystemFont(ofSize: font.pointSize)
    }

    private var markerWidth: CGFloat {
        marker.map { Self.width(of: $0, font: markerFont) } ?? 0
    }

    private static func width(of text: String, font: UIFont) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font]).width
    }
}

#Preview("Markers", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: true)
}

#Preview("Long names, one column", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.previewLongNames(count: 3)
}

#Preview("Long names, two columns, ⋮", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.previewLongNames(count: 6, cutEnding: .verticalEllipsis)
}

#Preview("Long names, two columns, …", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.previewLongNames(count: 6, cutEnding: .ellipsis)
}

#Preview("Long names, two columns, no mark", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.previewLongNames(count: 6, cutEnding: .empty)
}

#Preview("Home Screen, markers", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(showsOverdueTasks: true, showsTomorrowTasks: true)
}

#Preview("Home Screen, long names", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.previewLongNames(count: 6)
}
