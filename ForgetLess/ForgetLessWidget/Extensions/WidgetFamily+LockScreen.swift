import WidgetKit

// The timeline provider reads it too, off the main actor.
nonisolated extension WidgetFamily {
    var isOnLockScreen: Bool {
        switch self {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline: true
        default: false
        }
    }
}
