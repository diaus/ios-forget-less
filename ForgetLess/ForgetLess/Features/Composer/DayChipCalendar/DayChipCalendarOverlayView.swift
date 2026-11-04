import FactoryKit
import SwiftUI

/// The Day chip calendar, with what closes it on a touch anywhere else.
struct DayChipCalendarOverlayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let anchors: DayChipCalendarAnchors

    /// The widest the calendar grows, so its Days never spread out on a wide screen.
    private let maxWidth: CGFloat = 400
    /// Kept clear above the calendar, so it never touches the top of the safe area.
    private let topMargin: CGFloat = 8
    private let coordinateSpaceName = "dayChipCalendarOverlay"

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let chip = anchors.chip.map { proxy[$0] }
            let composer = anchors.composer.map { proxy[$0] }
            ZStack(alignment: .topLeading) {
                if vm.dayChipCalendar != nil {
                    backdrop(composerFrame: composer)
                }
                if let calendar = vm.dayChipCalendar, let chip, let composer {
                    FloatingDayCalendarView(
                        calendar: binding(keeping: calendar),
                        availableHeight: composer.maxY - topMargin,
                        isKeyboardUp: !calendar.hasHiddenKeyboard,
                        onHideKeyboard: vm.hideKeyboardForDayChipCalendar,
                        onChoose: vm.chooseDayChipCalendarDay,
                        onClose: vm.closeDayChipCalendarRestoringFocus
                    )
                        .frame(width: min(composer.width, maxWidth))
                        .padding(.leading, composer.minX)
                        // Covers the composer, for the most height for its month.
                        .frame(width: proxy.size.width, height: composer.maxY, alignment: .bottomLeading)
                        .transition(
                            .scale(scale: 0.1, anchor: chipCorner(chip, in: proxy.size, above: composer.maxY))
                                .combined(with: .opacity)
                        )
                }
            }
            .animation(.snappy(duration: 0.25), value: vm.dayChipCalendar == nil)
        }
        .coordinateSpace(.named(coordinateSpaceName))
    }

    // MARK: - UI Components
    /// Takes every touch outside the calendar, so a touch on the list or the composer, chip included, only closes the
    /// calendar. Keyboard input isn't a touch, so typing still reaches the name field.
    private func backdrop(composerFrame: CGRect?) -> some View {
        Color.clear
            .contentShape(.rect)
            .ignoresSafeArea()
            .gesture(backdropDrag(composerFrame: composerFrame))
    }

    // MARK: - Gestures
    /// Closes the calendar on any touch; a drag from the composer that would dismiss it there dismisses it too.
    private func backdropDrag(composerFrame: CGRect?) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpaceName))
            .onEnded { value in
                if let composerFrame, composerFrame.contains(value.startLocation), value.dismissesComposer {
                    // The composer goes too, so the keyboard isn't brought back.
                    vm.closeDayChipCalendar()
                    vm.requestComposerDismissal()
                } else {
                    vm.closeDayChipCalendarRestoringFocus()
                }
            }
    }

    // MARK: - Helpers
    /// The open calendar's state, or `calendar` once it has closed, while it animates out. A closed calendar takes
    /// no change, so it never opens again from one.
    private func binding(keeping calendar: FloatingDayCalendarState) -> Binding<FloatingDayCalendarState> {
        Binding { vm.dayChipCalendar ?? calendar } set: { newValue in
            if vm.dayChipCalendar != nil {
                vm.dayChipCalendar = newValue
            }
        }
    }

    /// Where the calendar grows from and shrinks back into.
    private func chipCorner(_ chip: CGRect, in size: CGSize, above bottom: CGFloat) -> UnitPoint {
        UnitPoint(x: chip.minX / max(size.width, 1), y: chip.maxY / max(bottom, 1))
    }
}
