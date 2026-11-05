import Domain
import SwiftUI
import UIKit
import Utils
import WidgetKit

/// The Tasks the Home Screen widget lists, in the Schedule's order, leaving out from the end those that don't fit.
struct HomeScreenRowsView: View {
    let rows: [UpcomingRow]

    @Environment(\.widgetFamily) private var family

    // Tuned with RenderPreview on iPhone 18 Pro: 5 rows at the full font and gap fill the height, and 6 still fit at
    // the full font with the smallest gap. The smallest font size is the Lock Screen's on iPhone 18 Pro.
    private static let sizing = TextRowsSizing(
        fullFontSize: 17,
        fullGap: 5,
        smallestGap: 1,
        smallestFontSize: 12,
        lineHeightPerPoint: UIFont.systemLineHeight(ofSize: 1)
    )

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let layout = Self.sizing.layout(rowCount: rows.count, height: proxy.size.height)
            let font = UIFont.systemFont(ofSize: layout.fontSize)
            let leavesRowsOut = layout.rowCount < rows.count
            VStack(alignment: .leading, spacing: layout.gap) {
                ForEach(Array(rows.prefix(layout.rowCount).enumerated()), id: \.element.id) { index, row in
                    if family == .systemLarge {
                        rowWithControls(
                            row,
                            font: font,
                            isLastShownBeforeRowsLeftOut: leavesRowsOut && index == layout.rowCount - 1
                        )
                    } else {
                        UpcomingRowView(row: row, font: font, cutWidth: nil, cutEnding: .empty)
                            .frame(height: font.lineHeight)
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
