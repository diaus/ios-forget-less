import Domain
import FactoryKit
import SwiftUI

/// A Task's row in the Schedule.
struct TaskRowView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let task: TodoTask
    /// Whether the row names its Day, which its section header doesn't.
    let showsDay: Bool
    let composerOpenerFocus: ComposerOpenerFocus
    /// Asks the owner to show the composer on this Task, to rename it.
    let onRename: () -> Void

    /// The circle's grey, which keeps a white checkmark legible in both appearances.
    private let circleGray = Color(uiColor: .systemGray)

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            Button { vm.toggleComplete(task) } label: {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    // `circle` has one layer, so it takes the first style.
                    .foregroundStyle(task.isComplete ? .white : circleGray, circleGray)
            }
            .padding(.trailing, 10)
            // Only the circle takes the tap, not the whole row: a row tap is for renaming.
            .buttonStyle(.borderless)
            .accessibilityLabel(accessibilityName)
            .accessibilityValue(Text(task.isComplete ? .taskComplete : .taskIncomplete))
            // Listed after Rename, which comes first as the row's tap.
            .accessibilityActions { moveActions }
            // The row's tap, for VoiceOver, which activates the circle.
            .accessibilityAction(named: Text(.taskRename), onRename)
            .accessibilityFocused(returningTo: .task(task.id), from: composerOpenerFocus)
            Group {
                Text(task.name)
                    .lineLimit(2)
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
    }

    // MARK: - UI Components
    /// VoiceOver's way to move the Task, offered only for a step that leads somewhere.
    @ViewBuilder private var moveActions: some View {
        // In reverse, as VoiceOver lists them: Move Up first.
        if vm.movesTasks {
            if let destination = vm.schedule.destinationOneStepDown(for: task) {
                Button { vm.moveAnnouncingDay(task, to: destination) } label: { Text(.taskMoveDown) }
            }
            if let destination = vm.schedule.destinationOneStepUp(for: task) {
                Button { vm.moveAnnouncingDay(task, to: destination) } label: { Text(.taskMoveUp) }
            }
        }
    }

    // MARK: - Helpers
    private var accessibilityName: Text {
        showsDay ? Text(.taskNameOnDay(name: task.name, day: task.day.shortDate(today: vm.today))) : Text(task.name)
    }
}

#Preview {
    let composerOpenerFocus = ComposerOpenerFocus()
    List {
        TaskRowView(task: .previewOverdue, showsDay: true, composerOpenerFocus: composerOpenerFocus) {}
        TaskRowView(task: .previewIncomplete, showsDay: false, composerOpenerFocus: composerOpenerFocus) {}
        TaskRowView(task: .previewComplete, showsDay: false, composerOpenerFocus: composerOpenerFocus) {}
    }
}
