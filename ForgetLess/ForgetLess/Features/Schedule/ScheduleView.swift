import Domain
import FactoryKit
import SwiftUI

/// The app's one screen: a section per Day of the Schedule, with the composer over it.
struct ScheduleView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    @FocusState private var isComposerNameFocused: Bool

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .ignoresSafeArea(.keyboard)
                .accessibilityHidden(vm.composer.isVisible)
            Color.black.opacity(vm.composer.isVisible ? 0.3 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(vm.composer.isVisible)
                .onTapGesture(perform: dismissComposer)
                .animation(.easeOut(duration: 0.2), value: vm.composer.isVisible)
            // Mounted while hidden, so its field can take focus in the same action that shows it and the keyboard
            // starts in the same frame. Opacity, not removal or `.hidden()`: the field stays focusable while hidden.
            ComposerView(isNameFocused: $isComposerNameFocused, onDismiss: dismissComposer)
                .opacity(vm.composer.isVisible ? 1 : 0)
                .allowsHitTesting(vm.composer.isVisible)
                .accessibilityHidden(!vm.composer.isVisible)
        }
        .task { await vm.load() }
        .errorAlert(message: $vm.errorMessage)
    }

    // MARK: - UI Components
    private var content: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach(vm.schedule.days) { scheduleDay in
                    Section {
                        ForEach(scheduleDay.tasks) { task in
                            TaskRowView(task: task)
                        }
                    } header: {
                        dayHeader(scheduleDay)
                    }
                }
            }
            // Room under the last row, so the floating "+" never covers it.
            .contentMargins(.bottom, 88, for: .scrollContent)
            Button { showComposer(on: vm.today) } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.tint, in: .circle)
            }
            .accessibilityLabel(Text(.taskAdd))
            .padding(20)
            // Its own container, so the rotor's Containers moves between it and the List.
            .accessibilityElement(children: .contain)
        }
    }

    /// The Day's date and weekday with its "+": bold primary when the Day has any Task, grey when it has none.
    private func dayHeader(_ scheduleDay: Schedule.Day) -> some View {
        let header = scheduleDay.day.dayHeader(today: vm.today)
        return HStack {
            Text(header)
            Spacer()
            Button { showComposer(on: scheduleDay.day) } label: {
                Image(systemName: "plus")
            }
            // Only the "+" takes the tap, not the whole header.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(.taskAddToDay(day: header)))
        }
        .font(.subheadline.weight(scheduleDay.tasks.isEmpty ? .regular : .bold))
        .foregroundStyle(scheduleDay.tasks.isEmpty ? .secondary : .primary)
        .textCase(nil)
    }

    // MARK: - Actions
    /// Shows the panel and focuses its field in one synchronous action, so the keyboard starts in the same frame.
    private func showComposer(on day: Date) {
        vm.showComposer(on: day)
        isComposerNameFocused = true
    }

    private func dismissComposer() {
        vm.dismissComposer()
        isComposerNameFocused = false
    }
}

#Preview {
    ScheduleView()
}
