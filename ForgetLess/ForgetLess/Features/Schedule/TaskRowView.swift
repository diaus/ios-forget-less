import Domain
import FactoryKit
import SwiftUI

/// A Task's row in the Schedule.
struct TaskRowView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let task: TodoTask
    var focusedComposerOpener: AccessibilityFocusState<ScheduleView.ComposerOpener?>.Binding
    /// Asks the owner to show the composer on this Task, to rename it.
    let onRename: () -> Void

    /// The circle's grey, which keeps a white checkmark legible in both appearances.
    private let circleGray = Color(uiColor: .systemGray)

    var body: some View {
        HStack(spacing: 12) {
            Button { vm.toggleComplete(task) } label: {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    // `circle` has one layer, so it takes the first style.
                    .foregroundStyle(task.isComplete ? .white : circleGray, circleGray)
            }
            // Only the circle takes the tap, not the whole row: a row tap is for renaming.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(task.name))
            .accessibilityValue(Text(task.isComplete ? .taskComplete : .taskIncomplete))
            // The row's tap, for VoiceOver, which activates the circle.
            .accessibilityAction(named: Text(.taskRename), onRename)
            .accessibilityFocused(focusedComposerOpener, equals: .task(task.id))
            Text(task.name)
                .strikethrough(task.isComplete)
                .foregroundStyle(task.isComplete ? .secondary : .primary)
                // VoiceOver reads the name on the circle, with its state.
                .accessibilityHidden(true)
        }
        // The whole row's width takes the tap, not just the name.
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .onTapGesture(perform: onRename)
    }
}
