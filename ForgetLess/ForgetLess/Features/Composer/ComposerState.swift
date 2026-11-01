import Domain
import Foundation
import Utils

/// What the composer shows. Focus is view state, so the view holds it.
struct ComposerState {
    var isVisible = false
    var taskName = ""
    var day: Date
    /// The Task being edited; `nil` while adding.
    var editedTask: TodoTask?
    /// Whether the user has stepped the Day since the composer showed.
    private(set) var hasSteppedDay = false
    /// The Days a Task was added to since the composer showed.
    var daysAddedTo: Set<Date> = []

    /// Whether the typed name can be saved as a Task's name.
    var canSubmit: Bool {
        !taskName.trimmed.isEmpty
    }

    /// Whether dismissing would drop what the user typed: a name to add, or a rename. A stepped Day alone isn't one:
    /// an edited Task's is already saved.
    var hasChanges: Bool {
        guard let editedTask else { return canSubmit }
        return taskName.trimmed != editedTask.name
    }

    /// Whether closing the composer should bring its Day into view: the Day was stepped to, and holds the Task edited
    /// or one added there.
    var revealsDayOnDismiss: Bool {
        hasSteppedDay && (editedTask != nil || daysAddedTo.contains(day))
    }

    /// Starts the composer afresh on `day`, nothing stepped to or added yet.
    mutating func start(on day: Date) {
        self.day = day
        hasSteppedDay = false
        daysAddedTo = []
    }

    mutating func step(to day: Date) {
        self.day = day
        hasSteppedDay = true
    }
}
