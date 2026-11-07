import Domain
import FactoryKit
import SwiftUI

/// The Schedule screen.
struct ScheduleView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    @Environment(\.scenePhase) private var scenePhase
    /// What the list shows, between its bars, which the floating Day picker opened from a row keeps within.
    @State private var listFrame: CGRect = .zero
    /// The sheet Day picker's height, which each opening starts at large.
    @State private var sheetDayPickerDetent = PresentationDetent.large

    private var session: ComposerSession {
        vm.composerSession
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .ignoresSafeArea(.keyboard)
                .accessibilityHidden(session.composer.isVisible)
            composerScrim
            composerPanel
        }
        // Over the composer rather than in it, so the picker can use the space above it.
        .overlayPreferenceValue(DayChipPickerAnchorsKey.self) { anchors in
            DayChipPickerOverlayView(anchors: anchors)
        }
        // Over everything, the add button included, so a touch anywhere else only closes it.
        .overlay {
            FloatingDayPickerOverlayView(listFrame: listFrame)
        }
        // Restarts on a new Today, on a new History first Day, and on coming back, when a fresh fetch also picks up
        // changes made outside the app.
        .task(id: ScheduleObservation(
            today: vm.today, historyFirstDay: vm.historyFirstDay, isActive: scenePhase == .active
        )) {
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
        .sheet(isPresented: isSheetDayPickerPresented, onDismiss: sheetDayPickerDidClose) {
            SheetDayPickerView()
                .presentationDetents([.medium, .large], selection: $sheetDayPickerDetent)
        }
        .errorAlert(message: Bindable(vm.writes).errorMessage)
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

    private var composerScrim: some View {
        Color.black.opacity(session.composer.isVisible ? 0.3 : 0)
            .ignoresSafeArea()
            .allowsHitTesting(session.composer.isVisible)
            .onTapGesture(perform: session.requestDismissal)
            .animation(.easeOut(duration: 0.2), value: session.composer.isVisible)
    }

    private var composerPanel: some View {
        // Mounted while hidden, so its field can take focus in the same update that shows it and the keyboard starts
        // in the same frame. Opacity, not removal or `.hidden()`: the field stays focusable while hidden.
        ComposerView()
            .opacity(session.composer.isVisible ? 1 : 0)
            .allowsHitTesting(session.composer.isVisible)
            .accessibilityHidden(!session.composer.isVisible)
            // An alert, not a confirmation dialog: as a popover, iOS 27 hides the dialog's Keep Editing.
            .alert(Text(.composerDiscardChanges), isPresented: Bindable(session).composer.isConfirmingDiscard) {
                Button(role: .destructive, action: session.dismiss) { Text(.composerDiscard) }
                Button(role: .cancel) { session.composer.keepEditing() } label: { Text(.composerKeepEditing) }
            }
    }

    private var addFloatingButton: some View {
        Button { session.show(on: vm.today, from: .floating) } label: {
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
            ScheduleListView(safeAreaInsets: proxy.safeAreaInsets)
                .ignoresSafeArea()
                // A Task completed while Complete Tasks are hidden leaves when its grace period ends.
                .animation(.default, value: vm.keptTasks.ids)
        }
        // Already between the bars, though its safe area still names them for the list that runs under them.
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { listFrame = $0 }
    }

    // MARK: - Actions
    private func sheetDayPickerDidClose() {
        // Back to large, so a sheet dragged down to medium doesn't open there next time.
        sheetDayPickerDetent = .large
        vm.sheetDayPickerDidClose()
    }

    // MARK: - Helpers
    private var isSheetDayPickerPresented: Binding<Bool> {
        // Bound by hand: the picker's state is `nil` while it's closed.
        Binding { vm.sheetDayPicker?.isVisible ?? false } set: { vm.sheetDayPicker?.isVisible = $0 }
    }

    /// What the Schedule is observed for; a change restarts the observation.
    private struct ScheduleObservation: Equatable {
        let today: Date
        let historyFirstDay: Date?
        let isActive: Bool
    }
}

#Preview(traits: .sampleTasks) {
    NavigationStack {
        ScheduleView()
    }
}
