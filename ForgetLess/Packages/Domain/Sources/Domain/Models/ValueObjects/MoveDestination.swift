import Foundation

/// Where a moved Task goes: a Day, and the Task it goes right after.
public struct MoveDestination: Hashable, Sendable {
    public let day: Date
    /// The ID of the Task the moved Task goes right after, or `nil` for first in the Day.
    public let after: UUID?

    public init(day: Date, after: UUID?) {
        self.day = day
        self.after = after
    }
}
