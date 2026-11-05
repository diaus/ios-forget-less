import Domain
import UIKit

/// A Task's row being moved in the Schedule's list, from lift to drop, with the haptics the user feels on the way.
final class TaskRowMove {
    /// The Task whose row is lifted, while it's being moved.
    private(set) var taskID: TodoTask.ID?
    /// The section the row last entered.
    private var section: Int?
    private let liftFeedback = UIImpactFeedbackGenerator(style: .light)
    private let dayFeedback = UISelectionFeedbackGenerator()

    func lift(_ id: TodoTask.ID) {
        guard taskID != id else { return }
        taskID = id
        liftFeedback.impactOccurred()
        dayFeedback.prepare()
    }

    /// Ticks when the row enters a section other than the last one it entered. `section` is `nil` where the move rule
    /// refuses the row, which enters nothing.
    func tickOnEntering(_ section: Int?, startedIn originalSection: Int) {
        // The list asks first at lift, before the row reports it's lifted: that's where the row starts, with no tick.
        let lastSection = self.section ?? originalSection
        self.section = lastSection
        // A refused section is never entered, so coming back from it ticks nothing.
        guard let section, section != lastSection else { return }
        self.section = section
        dayFeedback.selectionChanged()
    }

    func end() {
        taskID = nil
        section = nil
    }
}
