import Foundation

public extension Array where Element == UpcomingRow {
    /// The step down the row at `index` offers when only the first `shownRowCount` of these rows are shown: none that
    /// would put its Task after a row left out, so a step never takes a Task out of sight.
    /// - Parameter self: The rows the widget lists, in order.
    func stepDown(ofRowAt index: Int, shownRowCount: Int) -> MoveDestination? {
        let leavesRowsOut = shownRowCount < count
        // A step down that passes a Task lands just after the next Incomplete row, as kept rows are passed over.
        let hasIncompleteRowShownBelow = self[(index + 1)..<Swift.max(index + 1, shownRowCount)]
            .contains { !$0.isComplete }
        return self[index].oneStepDestinations.stepDown(
            allowingPassingATask: !leavesRowsOut || hasIncompleteRowShownBelow
        )
    }
}
