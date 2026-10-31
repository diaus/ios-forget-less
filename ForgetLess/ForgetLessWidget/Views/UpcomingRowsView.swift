import SwiftUI
import UIKit
import Utils
import WidgetKit

/// The Tasks the widget lists, in the Schedule's order.
struct UpcomingRowsView: View {
    let rows: [UpcomingRow]
    let cutEnding: CutEnding

    private static let columnRowCount = UpcomingWidgetContent.columnRowCount
    private static let columnSpacing: CGFloat = 1
    private static let lineWidth: CGFloat = 1
    private static let lineDash: [CGFloat] = [2, 4]

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let rowHeight = proxy.size.height / CGFloat(Self.columnRowCount)
            let font = UIFont.systemFont(ofSize: Self.fontSize(fittingRowHeight: rowHeight))
            if rows.count <= Self.columnRowCount {
                column(rows, rowHeight: rowHeight, font: font, cutWidth: nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            } else {
                twoColumns(size: proxy.size, rowHeight: rowHeight, font: font)
            }
        }
    }

    // MARK: - UI Components
    private func twoColumns(size: CGSize, rowHeight: CGFloat, font: UIFont) -> some View {
        let leftCount = (rows.count + 1) / 2
        let columnWidth = (size.width - Self.columnSpacing - Self.lineWidth) / 2
        return HStack(alignment: .top, spacing: 0) {
            column(rows.prefix(leftCount), rowHeight: rowHeight, font: font, cutWidth: columnWidth)
                .frame(width: columnWidth, alignment: .leading)
            VLine()
                .stroke(style: StrokeStyle(lineWidth: Self.lineWidth, dash: Self.lineDash))
                .frame(width: Self.lineWidth, height: CGFloat(leftCount) * rowHeight)
                .foregroundStyle(.secondary)
                .padding(.trailing, Self.columnSpacing)
            column(rows.dropFirst(leftCount), rowHeight: rowHeight, font: font, cutWidth: columnWidth)
                .frame(width: columnWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// `cutWidth` is the width the widget cuts each name to itself; nil leaves the cut to the system.
    private func column(
        _ rows: some RandomAccessCollection<UpcomingRow>,
        rowHeight: CGFloat,
        font: UIFont,
        cutWidth: CGFloat?
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(rows) { row in
                UpcomingRowView(row: row, font: font, cutWidth: cutWidth, cutEnding: cutEnding)
                    .frame(height: rowHeight)
            }
        }
    }

    // MARK: - Helpers
    /// The largest font size whose line fits in `rowHeight`.
    private static func fontSize(fittingRowHeight rowHeight: CGFloat) -> CGFloat {
        let lineHeightPerPoint = UIFont.systemFont(ofSize: 100).lineHeight / 100
        return (rowHeight / lineHeightPerPoint).rounded(.down)
    }
}

#Preview("1 Task", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 1)
}

#Preview("4 Tasks", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 4)
}

#Preview("5 Tasks", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 5)
}

#Preview("7 Tasks", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 7)
}

#Preview("8 Tasks", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 8)
}

#Preview("11 Tasks, the first 8 listed", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 11)
}

#Preview("Two columns off, 8 Tasks, the first 4 listed", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 8, showsTwoColumns: false)
}
