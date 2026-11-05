import Domain
import Foundation

/// One Task as the widget lists it.
nonisolated struct UpcomingRow: Hashable, Identifiable {
    /// What a row's marker tells apart from Today's Tasks, which have none.
    enum Marker {
        case overdue
        case tomorrow
    }

    let id: UUID
    let name: String
    let marker: Marker?
    /// Where the Task goes one step up or down, which only the large size offers.
    let oneStepDestinations: OneStepDestinations

    init(id: UUID, name: String, marker: Marker?, oneStepDestinations: OneStepDestinations) {
        self.id = id
        self.name = name
        self.marker = marker
        self.oneStepDestinations = oneStepDestinations
    }

    init(task: TodoTask, today: Date, oneStepDestinations: OneStepDestinations) {
        let marker: Marker? = switch task.day.relativeDay(today: today) {
        case .beforeToday: .overdue
        case .today: nil
        // The widget lists nothing after Tomorrow, so a later Day never comes up.
        case .tomorrow, .later: .tomorrow
        }
        self.init(id: task.id, name: task.name, marker: marker, oneStepDestinations: oneStepDestinations)
    }
}
