import Foundation
import Observation

/// Drives the Settings screen.
@MainActor @Observable
final class SettingsViewModel {
    /// How long, in seconds, a Task completed while Complete Tasks are hidden stays listed. Kept across launches.
    private(set) var keptDuration: Double {
        didSet {
            UserDefaults.standard.keptDuration = keptDuration
        }
    }
    var keptDurationEditor: KeptDurationEditorState

    init() {
        let keptDuration = UserDefaults.standard.keptDuration
        self.keptDuration = keptDuration
        self.keptDurationEditor = KeptDurationEditorState(seconds: keptDuration)
    }

    /// Shows the editor filled in with the current kept duration.
    func editKeptDuration() {
        keptDurationEditor = KeptDurationEditorState(seconds: keptDuration)
        keptDurationEditor.isVisible = true
    }

    /// Saves the typed kept duration. Does nothing when it can't be saved.
    func saveKeptDuration() {
        guard let seconds = keptDurationEditor.seconds else { return }
        keptDuration = seconds
    }
}
