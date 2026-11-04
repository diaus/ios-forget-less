import Domain
import Foundation

/// What the composer shows, and where its focus goes.
struct ComposerState {
    private(set) var isVisible = false
    /// Whether the name field has keyboard focus. The field follows it, and reports back focus it loses on its own.
    var isNameFocused = false
    /// Whether the composer is asking to discard what was typed before it dismisses.
    var isConfirmingDiscard = false
    /// Counts the returns of VoiceOver focus to the Day chip, so each one focuses it, even twice in a row.
    private(set) var dayChipAccessibilityFocusCount = 0
    var taskName = ""
    var day: Date
    /// The Task being edited; `nil` while adding.
    var editedTask: TodoTask?
    /// Whether the user has stepped the Day since the composer showed.
    private(set) var hasSteppedDay = false
    /// The Days a Task was added to since the composer showed.
    private(set) var daysAddedTo: Set<Date> = []

    // MARK: - Rules
    /// Whether the typed name can be saved as a Task's name.
    var canSubmit: Bool {
        TodoTask.savedName(from: taskName) != nil
    }

    /// Whether dismissing would drop what the user typed: a name to add, or a rename. A stepped Day alone isn't one:
    /// an edited Task's is already saved.
    var hasChanges: Bool {
        guard let editedTask else { return canSubmit }
        return TodoTask.savedName(from: taskName) != editedTask.name
    }

    /// Whether closing the composer should bring its Day into view: the Day was stepped to, and holds the Task edited
    /// or one added there.
    var revealsDayOnDismiss: Bool {
        hasSteppedDay && (editedTask != nil || daysAddedTo.contains(day))
    }

    // MARK: - Showing
    /// Shows the composer afresh on `day`, nothing stepped to or added yet, to add a Task.
    mutating func show(on day: Date) {
        self.day = day
        hasSteppedDay = false
        daysAddedTo = []
        // With the panel in the same update, so the keyboard starts in the same frame.
        isVisible = true
        isNameFocused = true
    }

    /// Shows the composer filled in with `task`, to edit it.
    mutating func show(editing task: TodoTask) {
        editedTask = task
        taskName = task.name
        show(on: task.day)
    }

    /// Hides the composer and drops what's typed, so the next add starts blank.
    mutating func hide() {
        isVisible = false
        isNameFocused = false
        editedTask = nil
        taskName = ""
    }

    /// Asks whether to discard what was typed. The panel stays up behind the question; only the keyboard goes.
    mutating func askToDiscard() {
        isNameFocused = false
        isConfirmingDiscard = true
    }

    /// Answers the discard question by going back to typing.
    mutating func keepEditing() {
        isNameFocused = true
    }

    // MARK: - Editing
    mutating func step(to day: Date) {
        self.day = day
        hasSteppedDay = true
    }

    /// Clears the name once a Task is added to `day`, for the next one.
    mutating func clearForNextTask(afterAddingTo day: Date) {
        taskName = ""
        daysAddedTo.insert(day)
        // Return would otherwise drop focus.
        isNameFocused = true
    }

    /// Gives focus back once a Day calendar or the Day picker over the composer closes: VoiceOver goes to the Day chip
    /// they opened from, and the keyboard comes back when `bringingBackKeyboard`.
    mutating func returnFocusToDayChip(bringingBackKeyboard: Bool) {
        if bringingBackKeyboard {
            isNameFocused = true
        }
        dayChipAccessibilityFocusCount += 1
    }
}
