import SwiftUI
import UIKit
import WidgetKit

/// One Task the widget lists.
struct UpcomingRowView: View {
    let row: UpcomingRow
    let font: UIFont
    /// The width the widget cuts the row to itself; nil leaves the cut to the system.
    let cutWidth: CGFloat?

    private static let cutEnding = "⋮"

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            if let marker {
                Text(verbatim: marker)
                    .font(Font(markerFont))
                    .fixedSize()
            }
            if let cutWidth {
                Text(verbatim: Self.name(row.name, cutToFit: cutWidth - markerWidth, font: font))
                    .font(Font(font))
                    // Already cut to fit, so the system never adds its own "…".
                    .fixedSize()
            } else {
                Text(verbatim: row.name)
                    .font(Font(font))
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Helpers
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

    /// `name` whole when it fits in `width`, or else its longest start that fits followed by "⋮".
    private static func name(_ name: String, cutToFit width: CGFloat, font: UIFont) -> String {
        guard Self.width(of: name, font: font) > width else { return name }
        let characters = Array(name)
        // Binary search for the longest start that fits with the ending.
        var fitting = 0
        var tooLong = characters.count
        while tooLong - fitting > 1 {
            let count = (fitting + tooLong) / 2
            let cut = String(characters[..<count]) + cutEnding
            if Self.width(of: cut, font: font) <= width {
                fitting = count
            } else {
                tooLong = count
            }
        }
        let start = String(characters[..<fitting])
        // A word cut before its space would read as a whole word, so the space goes too.
        return String(start.reversed().drop { $0.isWhitespace }.reversed()) + cutEnding
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

#Preview("Long names, two columns", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.previewLongNames(count: 6)
}
