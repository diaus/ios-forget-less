import Foundation

/// What opened the Day picker, and so what the Day it confirms is for.
enum DayPickerOrigin: Equatable {
    /// The row of the Task with this ID.
    case taskRow(UUID)
    /// The composer's Day chip.
    case composer

    /// The Task the picker keeps listed while it's open: the composer keeps its own.
    var taskID: UUID? {
        guard case let .taskRow(id) = self else { return nil }
        return id
    }
}
