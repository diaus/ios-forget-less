import Foundation

/// What the Schedule lists its Tasks by.
struct ScheduleListing: Equatable {
    let today: Date
    /// Whether Complete Tasks are listed.
    let showsComplete: Bool
    /// Tasks listed even while Complete Tasks are hidden.
    let keptTaskIDs: Set<UUID>
}
