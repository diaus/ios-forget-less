import Foundation

/// The floating Day picker opened from a Task's row, to Move that Task.
struct FloatingDayPickerPresentation {
    let taskID: UUID
    /// Where the Task's row was tapped, which the picker grows from.
    let origin: FloatingDayPickerOrigin
    var picker: FloatingDayPickerState
}
