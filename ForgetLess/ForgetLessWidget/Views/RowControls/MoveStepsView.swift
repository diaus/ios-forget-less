import AppIntents
import Domain
import SwiftUI
import UIKit
import WidgetKit

/// The large size's arrows, which Move their row's Task one step: the left half, under the up arrow, up, and the right
/// half, under the down arrow, down. A half with nowhere to go is dimmed and does nothing.
struct MoveStepsView: View {
    let taskID: UUID
    let stepUp: MoveDestination?
    let stepDown: MoveDestination?
    let font: UIFont

    private static let symbolName = "arrow.up.forward.and.arrow.down.backward.rectangle.fill"
    /// Each half's tap target, wider than half the glyph, so a thumb hits it.
    private static let halfTapWidth: CGFloat = 32
    private static let dimmedOpacity = 0.3

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            half(.leading, destination: stepUp, label: .taskMoveUp)
            half(.trailing, destination: stepDown, label: .taskMoveDown)
        }
        .foregroundStyle(.secondary)
    }

    // MARK: - UI Components
    @ViewBuilder
    private func half(
        _ edge: HorizontalEdge,
        destination: MoveDestination?,
        label: LocalizedStringResource
    ) -> some View {
        let isLeading = edge == .leading
        // Each half draws its own half of the glyph, so the two halves meet in the middle and can be dimmed apart.
        let glyph = Image(systemName: Self.symbolName)
            .font(Font(font))
            .frame(width: symbolWidth / 2, alignment: isLeading ? .leading : .trailing)
            .clipped()
            .frame(width: Self.halfTapWidth, height: font.lineHeight, alignment: isLeading ? .trailing : .leading)
            .contentShape(.rect)
        if let destination {
            Button(intent: MoveTaskIntent(taskID: taskID, to: destination)) { glyph }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(label))
        } else {
            glyph
                .opacity(Self.dimmedOpacity)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Helpers
    private var symbolWidth: CGFloat {
        let configuration = UIImage.SymbolConfiguration(font: font)
        return UIImage(systemName: Self.symbolName, withConfiguration: configuration)?.size.width ?? font.pointSize
    }
}
