import SwiftUI

extension DragGesture.Value {
    /// Whether this drag, once it ends, dismisses the composer.
    var dismissesComposer: Bool {
        // Mostly down, so a sideways swipe on the Day chip only steps its Day.
        guard translation.height > abs(translation.width) else { return false }
        let isFlung = predictedEndTranslation.height > Self.composerDismissDistance * 2
        return translation.height > Self.composerDismissDistance || isFlung
    }

    private static let composerDismissDistance: CGFloat = 60
}
