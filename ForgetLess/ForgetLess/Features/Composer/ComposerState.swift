import Domain
import Foundation
import Utils

/// What the composer shows. Focus is view state, so the view holds it.
struct ComposerState {
    var isVisible = false
    var taskName = ""
    var day: Date
    /// The Task being renamed; `nil` while adding.
    var editedTask: TodoTask?

    /// Whether the typed name can be saved as a Task's name.
    var canSubmit: Bool {
        !taskName.trimmed.isEmpty
    }

    /// Whether dismissing would drop what the user typed: a name to add, or a rename.
    var hasChanges: Bool {
        guard let editedTask else { return canSubmit }
        return taskName.trimmed != editedTask.name
    }
}
