import Domain
import FactoryKit
import SwiftUI

/// A Task's row in the Schedule.
struct TaskRowView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let task: TodoTask
    /// Whether the row names its Day, which its section header doesn't.
    let showsDay: Bool
    /// Asks the owner to show the composer on this Task, to edit it.
    let onEdit: () -> Void
    /// Asks the owner to show the floating Day calendar on this Task, to Move it.
    let onChooseDay: () -> Void

    /// Where a tap on the row stops editing the Task and opens its calendar instead.
    @State private var halvesSplitX: CGFloat = .infinity

    /// The circle's grey, which keeps a white checkmark legible in both appearances.
    private let circleGray = Color(uiColor: .systemGray)
    // Read by the tap and the measure, which run off the main actor.
    nonisolated private static let rowSpace = "taskRow"
    /// The list cell's own margin above and below its content, which the row draws instead.
    private static let verticalMargin: CGFloat = 11

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
            // Only the circle takes the tap, not the whole row: a row tap edits the Task or opens its calendar.
            .buttonStyle(.borderless)
            .accessibilityLabel(accessibilityName)
            .accessibilityValue(Text(task.isComplete ? .taskComplete : .taskIncomplete))
            // Listed after Edit, which comes first as the row's tap.
            .accessibilityActions { moveActions }
            // The row's tap, for VoiceOver, which activates the circle.
            .accessibilityAction(named: Text(.taskEdit), onEdit)
            .accessibilityFocused(returningTo: .task(task.id))
            HStack(spacing: 0) {
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
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.frame(in: .named(Self.rowSpace)).midX
            } action: { halvesSplitX = $0 }
            // VoiceOver reads the name and Day on the circle, with its state.
            .accessibilityHidden(true)
        }
        // The row's margins above and below are padding here, so its whole height takes the tap, not just the name's
        // lines.
        .padding(.vertical, Self.verticalMargin)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .coordinateSpace(.named(Self.rowSpace))
        .gesture(halvesTap)
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

    // MARK: - Gestures
    /// Edits the Task from the row's leading half, and opens its calendar from the trailing half, its Day included.
    private var halvesTap: some Gesture {
        SpatialTapGesture(coordinateSpace: .named(Self.rowSpace)).onEnded { value in
            if value.location.x < halvesSplitX {
                onEdit()
            } else {
                onChooseDay()
            }
        }
    }

    // MARK: - Helpers
    private var accessibilityName: Text {
        showsDay ? Text(.taskNameOnDay(name: task.name, day: task.day.shortDate(today: vm.today))) : Text(task.name)
    }
}

#Preview {
    List {
        TaskRowView(task: .previewOverdue, showsDay: true) {} onChooseDay: {}
        TaskRowView(task: .previewIncomplete, showsDay: false) {} onChooseDay: {}
        TaskRowView(task: .previewComplete, showsDay: false) {} onChooseDay: {}
    }
}
