import Foundation

/// What a Day chosen in a Day calendar or the Day picker is for.
enum DayChoiceTarget: Equatable {
    /// The composer's Day.
    case composer
    /// The Day of the Task with this ID.
    case task(UUID)

    /// The Task whose Day is chosen: the composer keeps its own listed.
    var taskID: UUID? {
        guard case let .task(id) = self else { return nil }
        return id
    }
}
