/// Where a listed Task goes one step up or one step down, past the Task listed beside it; nil where it can't go.
public struct OneStepDestinations: Hashable, Sendable {
    public let destinationOneStepUp: MoveDestination?
    public let destinationOneStepDown: MoveDestination?
    /// `destinationOneStepDown` for the last row shown while rows listed after it are left out: nil when the step would
    /// put the Task among them.
    public let destinationOneStepDownFromLastShownRow: MoveDestination?

    public init(
        destinationOneStepUp: MoveDestination?,
        destinationOneStepDown: MoveDestination?,
        destinationOneStepDownFromLastShownRow: MoveDestination?
    ) {
        self.destinationOneStepUp = destinationOneStepUp
        self.destinationOneStepDown = destinationOneStepDown
        self.destinationOneStepDownFromLastShownRow = destinationOneStepDownFromLastShownRow
    }
}
