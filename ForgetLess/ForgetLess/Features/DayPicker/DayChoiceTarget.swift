import Foundation

/// What a Day chosen in a floating Day picker or the sheet Day picker is for.
enum DayChoiceTarget: Equatable {
    /// The composer's Day.
    case composer
    /// The Day of the Task with this ID.
    case task(UUID)
    /// The Day of every Overdue Task, all moved to it at once.
    case overdueTasks
    /// The Day the Schedule's list goes to, in History.
    case goToDay

    /// The Task whose Day is chosen: the composer keeps its own listed, and the Overdue Tasks leave Overdue.
    var taskID: UUID? {
        guard case let .task(id) = self else { return nil }
        return id
    }
}
