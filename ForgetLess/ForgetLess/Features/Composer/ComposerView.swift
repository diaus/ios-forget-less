import FactoryKit
import SwiftUI

/// The quick-add panel for Tasks.
struct ComposerView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    var isNameFocused: FocusState<Bool>.Binding
    /// Asks the owner to dismiss the panel.
    let onDismiss: () -> Void

    // Animated reset, so a drag short of dismissing settles back instead of jumping.
    @GestureState(resetTransaction: Transaction(animation: .spring)) private var dragOffset: CGFloat = 0

    /// How far a drag must go to dismiss the panel.
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
        // A container, so VoiceOver's escape (two-finger scrub) from any of its elements dismisses, like the drag.
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, onDismiss)
    }

    // MARK: - Actions
    private func submit() {
        guard vm.composer.canSubmit else {
            onDismiss()
            return
        }
        // Return would otherwise drop focus, and the panel stays up for the next Task.
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
