import SwiftUI

extension SensoryFeedback {
    /// The haptic for a step or a page that's refused, so every refusal feels the same.
    static var refusal: SensoryFeedback {
        .impact(flexibility: .rigid, intensity: 0.5)
    }
}
