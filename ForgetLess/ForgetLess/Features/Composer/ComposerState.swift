import Domain
import Foundation
import Utils

/// What the composer shows. Focus is view state, so the view holds it.
struct ComposerState {
    var isVisible = false
    var taskName = ""
    var day: Date

    /// Whether the typed name can be added as a Task.
    var canSubmit: Bool {
        !taskName.trimmed.isEmpty
    }
}
