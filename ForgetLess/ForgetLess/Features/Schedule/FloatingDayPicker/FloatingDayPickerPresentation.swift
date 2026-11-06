import Foundation

/// The floating Day picker opened from a Task's row, to Move that Task, or from the Overdue header, to Move every
/// Overdue Task.
struct FloatingDayPickerPresentation {
    let target: DayChoiceTarget
    /// Where it was opened from, which the picker grows from.
    let origin: FloatingDayPickerOrigin
    var picker: FloatingDayPickerState
}
