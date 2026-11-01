import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct KeptDurationEditorStateTests {
    private nonisolated static let english = Locale(identifier: "en_US")
    private nonisolated static let ukrainian = Locale(identifier: "uk_UA")

    // MARK: - Tests
    @Test(arguments: [
        ("1.5", english, 1.5),
        ("0", english, 0),
        ("30", english, 30),
        (" 2.25\n", english, 2.25),
        (".5", english, 0.5),
        ("1,5", ukrainian, 1.5),
        ("1.5", ukrainian, 1.5),
    ])
    func aDecimalNumberWithinTheRangeIsSaved(text: String, locale: Locale, seconds: Double) {
        let editor = editor(text: text, locale: locale)

        #expect(editor.seconds == seconds)
        #expect(editor.canSave)
    }

    @Test(arguments: ["", " ", ".", "abc", "30.01", "31", "-1", "+1", "1e1", "inf", "nan", "1.2.3", "1,5", "1 5", "١"])
    func anythingElseIsRefused(text: String) {
        let editor = editor(text: text, locale: Self.english)

        #expect(editor.seconds == nil)
        #expect(!editor.canSave)
    }

    @Test(arguments: [(1.5, english), (1.5, ukrainian), (0.0, english), (30.0, ukrainian), (12.25, ukrainian)])
    func anEditorFilledInWithADurationSavesThatDuration(seconds: Double, locale: Locale) {
        let editor = KeptDurationEditorState(seconds: seconds, locale: locale)

        #expect(editor.seconds == seconds)
    }

    // MARK: - Helpers
    private func editor(text: String, locale: Locale) -> KeptDurationEditorState {
        var editor = KeptDurationEditorState(seconds: 0, locale: locale)
        editor.text = text
        return editor
    }
}
