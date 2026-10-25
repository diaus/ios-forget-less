import Domain
import Foundation

/// What the composer shows: whether it's up, the Task name being typed and the Day the Task goes to.
/// Focus isn't here: it's view state, set by the view in the same action that changes `isVisible`.
struct ComposerState {
    var isVisible = false
    var taskName = ""
    var day: Date

    /// Whether ▶ and Return add the Task: the name passes the name rule.
    var canSubmit: Bool {
        (try? validatedTaskName(taskName)) != nil
    }
}
