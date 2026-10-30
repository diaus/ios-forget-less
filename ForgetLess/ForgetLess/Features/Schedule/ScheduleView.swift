import Domain
import FactoryKit
import SwiftUI

/// The Schedule screen.
struct ScheduleView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isComposerNameFocused: Bool
    @AccessibilityFocusState private var focusedComposerOpener: ComposerOpener?
    /// What showed the composer, where VoiceOver returns when it's dismissed.
    @State private var composerOpener: ComposerOpener = .floating

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
        // Restarts on a new Today and on coming back, when a fresh fetch also picks up changes made outside the app.
        .task(id: ScheduleObservation(today: vm.today, isActive: scenePhase == .active)) {
            if scenePhase == .active {
                await vm.observeSchedule()
            }
        }
        // Today may have moved while the app was away.
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                vm.refresh()
            }
        }
        // Fires at midnight and on a time-zone change, either of which can change Today.
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            vm.refresh()
        }
        .errorAlert(message: $vm.errorMessage)
    }

    // MARK: - UI Components
    private var content: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if !vm.schedule.overdue.isEmpty {
                    overdueSection
                }
                ForEach(vm.schedule.days) { scheduleDay in
                    Section {
                        ForEach(scheduleDay.tasks) { task in
                            TaskRowView(task: task, showsDay: false, focusedComposerOpener: $focusedComposerOpener) {
                                showComposer(editing: task)
                            }
                        }
                    } header: {
                        dayHeader(scheduleDay)
                    }
                }
            }
            // Room under the last row, so the floating "+" never covers it.
            .contentMargins(.bottom, 88, for: .scrollContent)
            Button { showComposer(on: vm.today, from: .floating) } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.tint, in: .circle)
            }
            .accessibilityLabel(Text(.taskAdd))
            .accessibilityFocused($focusedComposerOpener, equals: .floating)
            .padding(20)
            // Its own container, so the rotor's Containers moves between it and the List.
            .accessibilityElement(children: .contain)
        }
    }

    private var overdueSection: some View {
        Section {
            ForEach(vm.schedule.overdue) { task in
                TaskRowView(task: task, showsDay: true, focusedComposerOpener: $focusedComposerOpener) {
                    showComposer(editing: task)
                }
            }
        } header: {
            // No "+": a Task can't be planned in the past.
            HStack {
                Text(.scheduleOverdue)
                Spacer()
            }
            // On the stack, as the Day headers do: on the Text, `.primary` resolves against the header's grey.
            .font(.subheadline.bold())
            .foregroundStyle(.primary)
            .textCase(nil)
        }
    }

    /// A Day section's header.
    private func dayHeader(_ scheduleDay: Schedule.Day) -> some View {
        let header = scheduleDay.day.dayHeader(today: vm.today)
        return HStack {
            Text(header)
            Spacer()
            Button { showComposer(on: scheduleDay.day, from: .day(scheduleDay.day)) } label: {
                Image(systemName: "plus")
            }
            // Only the "+" takes the tap, not the whole header.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(.taskAddToDay(day: header)))
            .accessibilityFocused($focusedComposerOpener, equals: .day(scheduleDay.day))
        }
        .font(.subheadline.weight(scheduleDay.tasks.isEmpty ? .regular : .bold))
        .foregroundStyle(scheduleDay.tasks.isEmpty ? .secondary : .primary)
        .textCase(nil)
    }

    // MARK: - Actions
    private func showComposer(on day: Date, from opener: ComposerOpener) {
        vm.showComposer(on: day)
        focusComposer(from: opener)
    }

    private func showComposer(editing task: TodoTask) {
        vm.showComposer(editing: task)
        focusComposer(from: .task(task.id))
    }

    /// Called in the same action that shows the panel, so the keyboard starts in the same frame.
    private func focusComposer(from opener: ComposerOpener) {
        isComposerNameFocused = true
        composerOpener = opener
    }

    private func dismissComposer() {
        vm.dismissComposer()
        isComposerNameFocused = false
        focusedComposerOpener = composerOpener
    }

    // MARK: - Helpers
    /// What showed the composer: a "+", or a Task's row.
    enum ComposerOpener: Hashable {
        case floating
        case day(Date)
        case task(UUID)
    }

    /// What the Schedule is observed for; a change restarts the observation.
    private struct ScheduleObservation: Equatable {
        let today: Date
        let isActive: Bool
    }
}

#Preview {
    ScheduleView()
}
