import FactoryKit
import SwiftUI

extension View {
    /// Takes VoiceOver focus when the composer that `opener` showed closes.
    func accessibilityFocused(returningTo opener: ComposerOpener) -> some View {
        modifier(ComposerOpenerFocusModifier(opener: opener))
    }
}

private struct ComposerOpenerFocusModifier: ViewModifier {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let opener: ComposerOpener

    // Each view holds its own focus state: the list's rows and headers are hosted in their own SwiftUI graphs, which
    // the Schedule's `@AccessibilityFocusState` can't reach.
    @AccessibilityFocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityFocused($isFocused)
            .onChange(of: vm.composerOpenerFocus.returnCount) {
                if vm.composerOpenerFocus.opener == opener {
                    isFocused = true
                }
            }
    }
}
