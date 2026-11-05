/// Where a listed Task goes one step up or one step down; nil where it can't go.
public struct OneStepDestinations: Hashable, Sendable {
    public let stepUp: MoveDestination?
    public let stepDown: MoveDestination?
    /// Whether the step down puts the Task after a listed Task that was below it, rather than only moving it to the
    /// top of a later Day.
    private let stepDownPassesATask: Bool

    public init(stepUp: MoveDestination?, stepDown: MoveDestination?, stepDownPassesATask: Bool) {
        self.stepUp = stepUp
        self.stepDown = stepDown
        self.stepDownPassesATask = stepDownPassesATask
    }

    /// `stepDown`, or nil when it would put the Task after a listed Task that was below it and that isn't allowed.
    public func stepDown(allowingPassingATask allowsPassingATask: Bool) -> MoveDestination? {
        allowsPassingATask || !stepDownPassesATask ? stepDown : nil
    }
}
