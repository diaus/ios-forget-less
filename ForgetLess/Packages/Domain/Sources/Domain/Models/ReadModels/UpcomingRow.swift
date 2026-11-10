import Foundation

/// One Task as the widget lists it.
public struct UpcomingRow: Hashable, Identifiable, Sendable {
    /// What a row's marker tells apart from Today's Tasks, which have none.
    public enum Marker: Sendable {
        case overdue
        case tomorrow
    }

    public let id: UUID
    public let name: String
    public let marker: Marker?
    /// Whether the Task is Complete, listed only for the widget's Grace Period.
    public let isComplete: Bool
    /// Where the Task goes one step up or down, which only the sizes with controls offer.
    public let oneStepDestinations: OneStepDestinations

    init(task: TodoTask, today: Date, oneStepDestinations: OneStepDestinations) {
        id = task.id
        name = task.name
        marker = switch task.day.relativeDay(today: today) {
        case .beforeToday, .yesterday: .overdue
        case .today: nil
        // The widget lists nothing after Tomorrow, so a later Day never comes up.
        case .tomorrow, .later: .tomorrow
        }
        isComplete = task.isComplete
        self.oneStepDestinations = oneStepDestinations
    }
}
