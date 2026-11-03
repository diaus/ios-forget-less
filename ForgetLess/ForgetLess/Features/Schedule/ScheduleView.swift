import Domain
import FactoryKit
import SwiftUI

/// The Schedule screen.
struct ScheduleView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isComposerNameFocused: Bool
    @AccessibilityFocusState private var isDayChipAccessibilityFocused: Bool
    @State private var isConfirmingDiscard = false
    /// Where the row was tapped that opened the floating Day calendar last.
    @State private var taskDayCalendarOrigin: TaskDayCalendarOrigin?
    /// What the list shows, between its bars, which the floating Day calendar opened from a row keeps within.
    @State private var listFrame: CGRect = .zero

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .ignoresSafeArea(.keyboard)
                .accessibilityHidden(vm.composer.isVisible)
            Color.black.opacity(vm.composer.isVisible ? 0.3 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(vm.composer.isVisible)
                .onTapGesture(perform: requestComposerDismissal)
                .animation(.easeOut(duration: 0.2), value: vm.composer.isVisible)
            // Mounted while hidden, so its field can take focus in the same action that shows it and the keyboard
            // starts in the same frame. Opacity, not removal or `.hidden()`: the field stays focusable while hidden.
            ComposerView(
                isNameFocused: $isComposerNameFocused,
                isDayChipAccessibilityFocused: $isDayChipAccessibilityFocused,
                onDismiss: requestComposerDismissal
            )
            .opacity(vm.composer.isVisible ? 1 : 0)
            .allowsHitTesting(vm.composer.isVisible)
            .accessibilityHidden(!vm.composer.isVisible)
            // An alert, not a confirmation dialog: as a popover, iOS 27 hides the dialog's Keep Editing.
            .alert(Text(.composerDiscardChanges), isPresented: $isConfirmingDiscard) {
                Button(role: .destructive, action: dismissComposer) { Text(.composerDiscard) }
                Button(role: .cancel, action: keepEditing) { Text(.composerKeepEditing) }
            }
        }
        // Over the composer rather than in it, so the calendar can use the space above it.
        .overlayPreferenceValue(DayChipCalendarAnchorsKey.self) { anchors in
            DayChipCalendarOverlayView(
                anchors: anchors,
                isNameFocused: $isComposerNameFocused,
                isDayChipAccessibilityFocused: $isDayChipAccessibilityFocused,
                onDismissComposer: requestComposerDismissal
            )
        }
        // Over everything, the add button included, so a touch anywhere else only closes it.
        .overlay {
            TaskDayCalendarOverlayView(origin: taskDayCalendarOrigin, listFrame: listFrame)
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
        // Bound by hand: the picker's state is `nil` while it's closed.
        .sheet(
            isPresented: Binding { vm.dayPicker?.isVisible ?? false } set: { vm.dayPicker?.isVisible = $0 },
            onDismiss: vm.dayPickerDidClose
        ) {
            DayPickerView()
                .presentationDetents([.medium, .large])
        }
        .errorAlert(message: $vm.errorMessage)
        // The quick settings bar stands in for a navigation bar; only screens pushed from it show one.
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - UI Components
    private var content: some View {
        ZStack(alignment: .bottomTrailing) {
            // Above the list rather than in it, so quick settings stay one tap away wherever it's scrolled.
            if #available(iOS 26, *) {
                scheduleList.safeAreaBar(edge: .top, alignment: .trailing) { QuickSettingsView() }
            } else {
                scheduleList.safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                    QuickSettingsView()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .background(.bar)
                }
            }
            addFloatingButton
        }
    }

    private var addFloatingButton: some View {
        Button { showComposer(on: vm.today, from: .floating) } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(.tint, in: .circle)
        }
        .accessibilityLabel(Text(.taskAdd))
        .accessibilityFocused(returningTo: .floating)
        .padding(20)
        // Its own container, so the rotor's Containers moves between it and the list.
        .accessibilityElement(children: .contain)
    }

    private var scheduleList: some View {
        // A wrapped view gets no safe area of its own, so it's read here and passed in. The list runs under the bar.
        GeometryReader { proxy in
            ScheduleListView(
                safeAreaInsets: proxy.safeAreaInsets,
                onAdd: { day in showComposer(on: day, from: .day(day)) },
                onEdit: showComposer(editing:),
                onChooseDay: showTaskDayCalendar
            )
            .ignoresSafeArea()
            // A Task completed while Complete Tasks are hidden leaves when its grace period ends.
            .animation(.default, value: vm.keptTaskIDs)
        }
        // Already between the bars, though its safe area still names them for the list that runs under them.
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { listFrame = $0 }
    }

    // MARK: - Actions
    private func showComposer(on day: Date, from opener: ComposerOpener) {
        vm.showComposer(on: day, from: opener)
        focusComposer()
    }

    private func showComposer(editing task: TodoTask) {
        vm.showComposer(editing: task)
        focusComposer()
    }

    private func showTaskDayCalendar(for task: TodoTask, from origin: TaskDayCalendarOrigin) {
        taskDayCalendarOrigin = origin
        vm.showTaskDayCalendar(for: task)
    }

    /// Called in the same action that shows the panel, so the keyboard starts in the same frame.
    private func focusComposer() {
        isComposerNameFocused = true
    }

    /// Dismisses the composer, first asking whether to discard any change.
    private func requestComposerDismissal() {
        if vm.composer.hasChanges {
            // The panel stays up behind the alert; only the keyboard goes.
            isComposerNameFocused = false
            isConfirmingDiscard = true
        } else {
            dismissComposer()
        }
    }

    private func keepEditing() {
        isComposerNameFocused = true
    }

    private func dismissComposer() {
        vm.dismissComposer()
        isComposerNameFocused = false
    }

    // MARK: - Helpers
    /// What the Schedule is observed for; a change restarts the observation.
    private struct ScheduleObservation: Equatable {
        let today: Date
        let isActive: Bool
    }
}

#Preview(traits: .sampleTasks) {
    NavigationStack {
        ScheduleView()
    }
}
