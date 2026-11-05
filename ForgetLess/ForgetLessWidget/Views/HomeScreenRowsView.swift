import Domain
import SwiftUI
import UIKit
import WidgetKit

/// The Tasks the Home Screen widget lists, in the Schedule's order, leaving out from the end those that don't fit.
struct HomeScreenRowsView: View {
    /// The font, the gap between rows, and how many rows fit, from the start.
    private struct RowsLayout {
        let font: UIFont
        let gap: CGFloat
        let rowCount: Int
    }

    let rows: [UpcomingRow]

    @Environment(\.widgetFamily) private var family

    // Tuned with RenderPreview on iPhone 18 Pro: 5 rows at the full font and gap fill the height, and 6 still fit at
    // the full font with the smallest gap.
    private static let fullFontSize: CGFloat = 17
    private static let fullGap: CGFloat = 5
    private static let smallestGap: CGFloat = 1
    // The Lock Screen's font size on iPhone 18 Pro, which the font never shrinks below.
    private static let smallestFontSize: CGFloat = 12

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let layout = Self.layout(rowCount: rows.count, height: proxy.size.height)
            let leavesRowsOut = layout.rowCount < rows.count
            VStack(alignment: .leading, spacing: layout.gap) {
                ForEach(Array(rows.prefix(layout.rowCount).enumerated()), id: \.element.id) { index, row in
                    if family == .systemLarge {
                        rowWithControls(
                            row,
                            font: layout.font,
                            isLastShownBeforeRowsLeftOut: leavesRowsOut && index == layout.rowCount - 1
                        )
                    } else {
                        UpcomingRowView(row: row, font: layout.font, cutWidth: nil, cutEnding: .empty)
                            .frame(height: layout.font.lineHeight)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    // MARK: - UI Components
    /// The large size's row, with its circle and arrows. `isLastShownBeforeRowsLeftOut` is whether rows listed after it
    /// don't fit, so a step down mustn't put the Task among them.
    private func rowWithControls(_ row: UpcomingRow, font: UIFont, isLastShownBeforeRowsLeftOut: Bool) -> some View {
        HStack(spacing: 0) {
            CompleteCircleView(taskID: row.id, font: font)
            UpcomingRowView(row: row, font: font, cutWidth: nil, cutEnding: .empty)
                .frame(maxWidth: .infinity, alignment: .leading)
            let destinations = row.oneStepDestinations
            MoveStepsView(
                taskID: row.id,
                destinationOneStepUp: destinations.stepUp,
                destinationOneStepDown: isLastShownBeforeRowsLeftOut && destinations.stepDownPassesATask
                    ? nil
                    : destinations.stepDown,
                font: font
            )
        }
        .frame(height: font.lineHeight)
    }

    // MARK: - Helpers
    private static func layout(rowCount: Int, height: CGFloat) -> RowsLayout {
        // Rows take the full font while they fit with the smallest gap, so the gaps shrink before the font does.
        var size = fullFontSize
        if UIFont.systemLineHeight(ofSize: size) * CGFloat(rowCount) + smallestGap * CGFloat(rowCount - 1) > height {
            size = max(fontSize(rowCount: rowCount, gap: smallestGap, height: height), smallestFontSize)
        }
        let rowHeight = UIFont.systemLineHeight(ofSize: size)
        let fittingCount = min(rowCount, Int((height + smallestGap) / (rowHeight + smallestGap)))
        let gap = fittingCount > 1
            ? min(fullGap, (height - rowHeight * CGFloat(fittingCount)) / CGFloat(fittingCount - 1))
            : fullGap
        return RowsLayout(font: UIFont.systemFont(ofSize: size), gap: gap, rowCount: fittingCount)
    }

    /// The largest font size whose `rowCount` lines, with `gap` between them, fit in `height`.
    private static func fontSize(rowCount: Int, gap: CGFloat, height: CGFloat) -> CGFloat {
        let rowHeight = (height - gap * CGFloat(rowCount - 1)) / CGFloat(rowCount)
        return UIFont.largestSystemFontSize(fittingLineHeight: rowHeight)
    }
}

#Preview("1 Task", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 1)
}

#Preview("5 Tasks", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 5)
}

#Preview("6 Tasks, smaller gaps", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 6)
}

#Preview("7 Tasks", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 7)
}

#Preview("8 Tasks, smaller font", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 8)
}

#Preview("11 Tasks, at most 8 listed", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry.preview(taskCount: 11)
}
