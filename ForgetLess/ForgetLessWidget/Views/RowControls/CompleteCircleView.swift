import AppIntents
import SwiftUI
import UIKit
import WidgetKit

/// The large size's circle, which makes its row's Task Complete.
struct CompleteCircleView: View {
    let taskID: UUID
    let font: UIFont

    /// Wider than the glyph, so a thumb hits it.
    private static let tapWidth: CGFloat = 32
    /// The app's circle grey (`TaskRowView`).
    private let circleGray = Color(uiColor: .systemGray)

    var body: some View {
        Button(intent: CompleteTaskIntent(taskID: taskID)) {
            Image(systemName: "circle")
                .font(Font(font))
                .foregroundStyle(circleGray)
                .frame(width: Self.tapWidth, height: font.lineHeight, alignment: .leading)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(.widgetCompleteTask))
    }
}
