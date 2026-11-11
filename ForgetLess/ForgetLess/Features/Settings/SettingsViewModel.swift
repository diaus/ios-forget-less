import Foundation
import Observation
import UIKit

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
    /// The app's version with its build, as the user quotes it to Support.
    let appVersion: String

    init() {
        let keptDuration = UserDefaults.standard.keptDuration
        self.keptDuration = keptDuration
        self.keptDurationEditor = KeptDurationEditorState(seconds: keptDuration)
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let build = info?["CFBundleVersion"] as? String ?? ""
        self.appVersion = "\(version) (\(build))"
    }

    // MARK: - Grace Period
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

    // MARK: - About
    func copyAppVersion() {
        UIPasteboard.general.string = appVersion
    }
}
