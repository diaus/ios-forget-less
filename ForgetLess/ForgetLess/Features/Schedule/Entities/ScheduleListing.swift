import Foundation

/// What the Schedule lists its Tasks by.
struct ScheduleListing: Equatable {
    let today: Date
    /// The moment listed at, which ends the hour a Task completed from Overdue stays there.
    let now: Date
    /// Whether Complete Tasks are listed.
    let showsComplete: Bool
    /// Tasks listed even while Complete Tasks are hidden.
    let keptTaskIDs: Set<UUID>
}
