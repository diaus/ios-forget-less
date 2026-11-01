import SwiftUI

extension View {
    /// Takes VoiceOver focus when the composer that `opener` showed closes.
    func accessibilityFocused(
        returningTo opener: ComposerOpener,
        from composerOpenerFocus: ComposerOpenerFocus
    ) -> some View {
        modifier(ComposerOpenerFocusModifier(opener: opener, composerOpenerFocus: composerOpenerFocus))
    }
}

private struct ComposerOpenerFocusModifier: ViewModifier {
    let opener: ComposerOpener
    let composerOpenerFocus: ComposerOpenerFocus

    // Each view holds its own focus state: the list's rows and headers are hosted in their own SwiftUI graphs, which
    // the Schedule's `@AccessibilityFocusState` can't reach.
    @AccessibilityFocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isFocused)
            .onChange(of: composerOpenerFocus.returnCount) {
                if composerOpenerFocus.opener == opener {
                    isFocused = true
                }
            }
    }
}
