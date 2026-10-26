import FactoryKit
import SwiftUI

/// The quick-add panel pinned above the keyboard, on the composer state of the shared Schedule view model.
///
/// Its owner shows and hides it, and keeps it mounted while hidden. Visibility and focus are separate: focus can leave
/// while the panel stays on screen.
struct ComposerView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    var isNameFocused: FocusState<Bool>.Binding
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
            TextField(text: $vm.composer.taskName, prompt: Text(.composerTaskName)) {
                Text(.composerTaskName)
            }
            .focused(isNameFocused)
            .onSubmit(submit)
            HStack {
                Text(vm.composer.day.dayChipLabel(today: vm.today))
                    .font(.subheadline)
                    .foregroundStyle(vm.composer.day.dayChipColor(today: vm.today))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.fill.tertiary, in: .capsule)
                Spacer()
                Button(action: submit) {
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.title3)
                }
                .disabled(!vm.composer.canSubmit)
                .accessibilityLabel(Text(.taskAdd))
            }
        }
        .padding(16)
        .background(.background.secondary, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .offset(y: max(dragOffset, 0))
        .gesture(dismissDrag)
    }

    // MARK: - Actions
    /// Adds the Task, keeping the panel up for the next one, with focus kept since Return would otherwise drop it.
    /// Return on a blank name dismisses the panel instead.
    private func submit() {
        guard vm.composer.canSubmit else {
            onDismiss()
            return
        }
        isNameFocused.wrappedValue = true
        vm.submitComposer()
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
