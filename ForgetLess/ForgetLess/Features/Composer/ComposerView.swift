import SwiftUI

/// The quick-add panel pinned above the keyboard.
///
/// It stays mounted while hidden, so its field can take focus in the same action that shows it
/// and the keyboard starts in the same frame. Visibility and focus are separate: focus can leave
/// while the panel stays on screen.
struct ComposerView: View {
    let isVisible: Bool
    var isNameFocused: FocusState<Bool>.Binding
    @Binding var taskName: String
    /// The Day the Task goes to, shown on the Day chip.
    let day: Date
    let today: Date
    /// Whether the name passes the name rule, so ▶ and Return can add the Task.
    let canSubmit: Bool
    /// Asks the owner to add the Task. The panel stays up, with focus kept, for the next one.
    let onSubmit: () -> Void
    /// Asks the owner to hide the panel and the keyboard together.
    let onDismiss: () -> Void

    // Animated reset, so a drag short of dismissing settles back instead of jumping.
    @GestureState(resetTransaction: Transaction(animation: .spring)) private var dragOffset: CGFloat = 0

    /// How far the panel must be dragged down, or flung, to dismiss.
    private let dismissDistance: CGFloat = 60

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TextField(_:text:) takes a catalog symbol only from iOS 26; on iOS 18 it goes through a Text.
            TextField(text: $taskName, prompt: Text(.composerTaskName)) {
                Text(.composerTaskName)
            }
            .focused(isNameFocused)
            .onSubmit(submit)
            HStack {
                Text(day.dayChipLabel(today: today))
                    .font(.subheadline)
                    .foregroundStyle(day.dayChipColor(today: today))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.fill.tertiary, in: .capsule)
                Spacer()
                Button(action: submit) {
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.title3)
                }
                .disabled(!canSubmit)
                .accessibilityLabel(Text(.taskAdd))
            }
        }
        .padding(16)
        .background(.background.secondary, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .offset(y: max(dragOffset, 0))
        .gesture(dismissDrag)
        // Opacity, not removal or `.hidden()`: the field stays focusable while the panel is hidden.
        .opacity(isVisible ? 1 : 0)
        .allowsHitTesting(isVisible)
        .accessibilityHidden(!isVisible)
    }

    // MARK: - Actions
    /// Return on a blank name does nothing; either way the field keeps focus, since Return would otherwise drop it.
    private func submit() {
        isNameFocused.wrappedValue = true
        onSubmit()
    }

    // MARK: - Gestures
    private var dismissDrag: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, offset, _ in
                offset = value.translation.height
            }
            .onEnded { value in
                let isFlung = value.predictedEndTranslation.height > dismissDistance * 2
                if value.translation.height > dismissDistance || isFlung {
                    onDismiss()
                }
            }
    }
}
