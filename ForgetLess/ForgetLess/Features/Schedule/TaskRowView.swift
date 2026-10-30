import Domain
import FactoryKit
import SwiftUI

/// A Task in the list: its circle, which toggles Complete, and its name, struck through and grey once Complete.
struct TaskRowView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let task: TodoTask

    /// The circle's grey, which keeps a white checkmark legible in both appearances.
    private let circleGray = Color(uiColor: .systemGray)

    var body: some View {
        HStack(spacing: 12) {
            Button { vm.toggleComplete(task) } label: {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    // A grey ring, or a white checkmark on a grey disc: the ring's one layer takes the first style.
                    .foregroundStyle(task.isComplete ? .white : circleGray, circleGray)
            }
            // Only the circle takes the tap, not the whole row: a row tap is for renaming.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(task.name))
            .accessibilityValue(Text(task.isComplete ? .taskComplete : .taskIncomplete))
            Text(task.name)
                .strikethrough(task.isComplete)
                .foregroundStyle(task.isComplete ? .secondary : .primary)
                // VoiceOver reads the name on the circle, with its state.
                .accessibilityHidden(true)
        }
    }
}
