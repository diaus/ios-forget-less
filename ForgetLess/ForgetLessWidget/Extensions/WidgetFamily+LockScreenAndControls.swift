import WidgetKit

// The timeline provider reads it too, off the main actor.
nonisolated extension WidgetFamily {
    var isOnLockScreen: Bool {
        switch self {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline: true
        default: false
        }
    }

    /// Whether the size's rows make a Task Complete and Move it.
    var hasControls: Bool {
        switch self {
        case .systemMedium, .systemLarge: true
        default: false
        }
    }
}
