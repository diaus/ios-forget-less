import FactoryKit
import SwiftUI

/// The Day chip calendar, with what closes it on a touch anywhere else.
struct DayChipCalendarOverlayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let anchors: DayChipCalendarAnchors
    /// Asks the owner to dismiss the composer.
    let onDismissComposer: () -> Void

    /// The widest the calendar grows, so its Days never spread out on a wide screen.
    private let maxWidth: CGFloat = 400
    /// The space between the calendar and the chip under it.
    private let chipGap: CGFloat = 8
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
                    DayChipCalendarView(calendar: calendar)
                        .frame(width: min(composer.width, maxWidth))
                        .frame(height: max(chip.minY - chipGap, 0), alignment: .bottom)
                        .offset(x: composer.minX)
                        .transition(.scale(scale: 0.1, anchor: .bottomLeading).combined(with: .opacity))
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
                vm.closeDayChipCalendar()
                if let composerFrame, composerFrame.contains(value.startLocation), value.dismissesComposer {
                    onDismissComposer()
                }
            }
    }
}
