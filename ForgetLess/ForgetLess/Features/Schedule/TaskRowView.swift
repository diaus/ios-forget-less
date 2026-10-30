import Domain
import FactoryKit
import SwiftUI

/// A Task's row in the Schedule.
struct TaskRowView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let task: TodoTask
    /// Whether the row names its Day, which its section header doesn't.
    let showsDay: Bool
    var focusedComposerOpener: AccessibilityFocusState<ScheduleView.ComposerOpener?>.Binding
    /// Asks the owner to show the composer on this Task, to rename it.
    let onRename: () -> Void

    @State private var isConfirmingDelete = false

    /// The circle's grey, which keeps a white checkmark legible in both appearances.
    private let circleGray = Color(uiColor: .systemGray)

    // MARK: - Body
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
            .accessibilityLabel(accessibilityName)
            .accessibilityValue(Text(task.isComplete ? .taskComplete : .taskIncomplete))
            // The row's tap, for VoiceOver, which activates the circle.
            .accessibilityAction(named: Text(.taskRename), onRename)
            .accessibilityFocused(focusedComposerOpener, equals: .task(task.id))
            VStack(alignment: .trailing, spacing: 2) {
                Text(task.name)
                    .strikethrough(task.isComplete)
                    .foregroundStyle(task.isComplete ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showsDay {
                    Text(task.day.shortDate(today: vm.today))
                        .font(.caption)
                        .foregroundStyle(Color(.overdueDay))
                }
            }
            // VoiceOver reads the name and Day on the circle, with its state.
            .accessibilityHidden(true)
        }
        // The whole row's width takes the tap, not just the name.
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .onTapGesture(perform: onRename)
        // No full swipe: deleting always asks first.
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            // No destructive role: the List would remove the row, and its dialog, before the user confirms.
            Button { isConfirmingDelete = true } label: {
                Label { Text(.taskDelete) } icon: { Image(systemName: "trash") }
                    .labelStyle(.iconOnly)
            }
            .tint(Color(.deleteAction))
        }
        .confirmationDialog(
            Text(.taskDeleteConfirmation(name: task.name)),
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) { vm.delete(task) } label: { Text(.taskDelete) }
        }
    }

    // MARK: - Helpers
    private var accessibilityName: Text {
        showsDay ? Text(.taskNameOnDay(name: task.name, day: task.day.shortDate(today: vm.today))) : Text(task.name)
    }
}
