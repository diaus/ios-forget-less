import Domain
import Foundation

/// Sample Tasks for SwiftUI previews, on Days around Today.
extension TodoTask {
    static let previewIncomplete = TodoTask(
        id: UUID(), name: "Buy oat milk", day: .today, completeDay: nil, sortIndex: 0
    )
    static let previewComplete = TodoTask(
        id: UUID(), name: "Call the dentist", day: .today, completeDay: .today, sortIndex: 1
    )
    static let previewTomorrow = TodoTask(
        id: UUID(), name: "Water the plants", day: Date.today.addingDays(1), completeDay: nil, sortIndex: 0
    )
    static let previewOverdue = TodoTask(
        id: UUID(), name: "Return the library books", day: Date.today.addingDays(-2), completeDay: nil, sortIndex: 0
    )

    static let previewAll: [TodoTask] = [previewIncomplete, previewComplete, previewTomorrow, previewOverdue]
}
