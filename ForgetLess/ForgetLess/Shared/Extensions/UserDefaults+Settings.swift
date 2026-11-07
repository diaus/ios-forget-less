import Foundation

/// The user's settings, kept across launches.
extension UserDefaults {
    private static let showsCompleteKey = "showsCompleteTasks"
    private static let keptDurationKey = "keptDuration"

    /// Whether the Schedule lists Complete Tasks.
    var showsComplete: Bool {
        get { object(forKey: Self.showsCompleteKey) as? Bool ?? true }
        set { set(newValue, forKey: Self.showsCompleteKey) }
    }

    /// How long, in seconds, a Task completed while Complete Tasks are hidden stays listed, so a mis-tap can be undone.
    var keptDuration: Double {
        get { object(forKey: Self.keptDurationKey) as? Double ?? 1.5 }
        set { set(newValue, forKey: Self.keptDurationKey) }
    }
}
