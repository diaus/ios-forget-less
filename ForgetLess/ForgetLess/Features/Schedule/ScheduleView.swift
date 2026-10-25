import SwiftUI

/// The app's one screen. A placeholder list until the Schedule list is built, with the composer over it.
struct ScheduleView: View {
    @State private var isComposerVisible = false
    @FocusState private var isComposerNameFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .ignoresSafeArea(.keyboard)
            Color.black.opacity(isComposerVisible ? 0.3 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(isComposerVisible)
                .onTapGesture(perform: dismissComposer)
                .animation(.easeOut(duration: 0.2), value: isComposerVisible)
            ComposerView(
                isVisible: isComposerVisible,
                isNameFocused: $isComposerNameFocused,
                onDismiss: dismissComposer
            )
        }
    }

    private var content: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(.dayToday)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Button(action: showComposer) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.tint, in: .circle)
            }
            .accessibilityLabel(Text(.taskAdd))
            .padding(20)
        }
    }

    /// Shows the panel and focuses its field in one synchronous action, so the keyboard starts in the same frame.
    private func showComposer() {
        isComposerVisible = true
        isComposerNameFocused = true
    }

    private func dismissComposer() {
        isComposerVisible = false
        isComposerNameFocused = false
    }
}

#Preview {
    ScheduleView()
}
