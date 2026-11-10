import AppIntents
import Domain
import SwiftUI
import UIKit
import WidgetKit

/// The arrows of the sizes with controls, which Move their row's Task one step up or down. An arrow with nowhere to go
/// is hidden.
struct MoveStepsView: View {
    let taskID: UUID
    let stepUp: MoveDestination?
    let stepDown: MoveDestination?
    let font: UIFont

    /// Each arrow's tap target, wider than the glyph, so a thumb hits it.
    private static let tapWidth: CGFloat = 32

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            arrow("arrowshape.up", destination: stepUp, label: .taskMoveUp)
            arrow("arrowshape.down", destination: stepDown, label: .taskMoveDown)
        }
        .foregroundStyle(.secondary)
    }

    // MARK: - UI Components
    @ViewBuilder
    private func arrow(
        _ symbolName: String,
        destination: MoveDestination?,
        label: LocalizedStringResource
    ) -> some View {
        if let destination {
            Button(intent: MoveTaskIntent(taskID: taskID, to: destination)) {
                Image(systemName: symbolName)
                    .font(Font(font))
                    .frame(width: Self.tapWidth, height: font.lineHeight)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(label))
        } else {
            // Keeps the arrow's place, so the arrows line up down the rows.
            Color.clear
                .frame(width: Self.tapWidth, height: font.lineHeight)
                .accessibilityHidden(true)
        }
    }
}
