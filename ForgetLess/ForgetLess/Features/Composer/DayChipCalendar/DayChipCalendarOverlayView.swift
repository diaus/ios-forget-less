import FactoryKit
import SwiftUI

/// The Day chip calendar, with what closes it on a touch anywhere else.
struct DayChipCalendarOverlayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let anchors: DayChipCalendarAnchors

    /// Kept clear above the calendar, so it never touches the top of the safe area.
    private let topMargin: CGFloat = 8
    private let coordinateSpaceName = "dayChipCalendarOverlay"

    private var session: ComposerSession {
        vm.composerSession
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let chip = anchors.chip.map { proxy[$0] }
            let composer = anchors.composer.map { proxy[$0] }
            ZStack(alignment: .topLeading) {
                if session.dayChipCalendar != nil {
                    backdrop(composerFrame: composer)
                }
                if let calendar = session.dayChipCalendar, let chip, let composer {
                    FloatingDayCalendarView(
                        calendar: FloatingDayCalendarView.binding(keeping: calendar) {
                            session.dayChipCalendar
                        } update: {
                            session.dayChipCalendar = $0
                        },
                        availableHeight: composer.maxY - topMargin,
                        isKeyboardUp: !calendar.hasHiddenKeyboard,
                        onHideKeyboard: session.hideKeyboardForDayChipCalendar,
                        onChoose: session.chooseDayChipCalendarDay,
                        onClose: session.closeDayChipCalendarRestoringFocus
                    )
                        .frame(width: min(composer.width, FloatingDayCalendarLayout.maxWidth))
                        .padding(.leading, composer.minX)
                        // Covers the composer, for the most height for its month.
                        .frame(width: proxy.size.width, height: composer.maxY, alignment: .bottomLeading)
                        // From the chip's corner, in the calendar's frame, which ends at the composer's bottom.
                        .transition(FloatingDayCalendarView.transition(
                            growingFrom: CGPoint(x: chip.minX, y: chip.maxY),
                            in: CGSize(width: proxy.size.width, height: composer.maxY)
                        ))
                }
            }
            .animation(FloatingDayCalendarView.appearanceAnimation, value: session.dayChipCalendar == nil)
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
                    session.closeDayChipCalendar()
                    session.requestDismissal()
                } else {
                    session.closeDayChipCalendarRestoringFocus()
                }
            }
    }
}
