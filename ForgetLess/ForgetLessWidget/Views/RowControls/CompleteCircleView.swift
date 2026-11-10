import AppIntents
import SwiftUI
import UIKit
import WidgetKit

/// The circle of the sizes with controls, which makes its row's Task Complete, or Incomplete again during the widget's
/// Grace Period.
struct CompleteCircleView: View {
    let taskID: UUID
    let isComplete: Bool
    let font: UIFont

    /// Wider than the glyph, so a thumb hits it.
    private static let tapWidth: CGFloat = 32
    /// The app's circle grey (`TaskRowView`).
    private let circleGray = Color(uiColor: .systemGray)

    var body: some View {
        Button(intent: CompleteTaskIntent(taskID: taskID, isComplete: !isComplete)) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .font(Font(font))
                // `circle` has one layer, so it takes the first style.
                .foregroundStyle(isComplete ? .white : circleGray, circleGray)
                .frame(width: Self.tapWidth, height: font.lineHeight, alignment: .leading)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isComplete ? .widgetMakeTaskIncomplete : .widgetCompleteTask))
    }
}
