import Observation

/// What showed the composer, where VoiceOver goes back to when the composer closes.
@MainActor @Observable
final class ComposerOpenerFocus {
    var opener: ComposerOpener = .floating
    /// Counts the returns, so each one focuses the opener, even the same opener twice in a row.
    private(set) var returnCount = 0

    func returnToOpener() {
        returnCount += 1
    }
}
