import FactoryKit
import SwiftUI

/// The Day chip picker, with what closes it on a touch anywhere else.
struct DayChipPickerOverlayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let anchors: DayChipPickerAnchors

    /// Kept clear above the picker, so it never touches the top of the safe area.
    private let topMargin: CGFloat = 8
    private let coordinateSpaceName = "dayChipPickerOverlay"

    private var session: ComposerSession {
        vm.composerSession
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let chip = anchors.chip.map { proxy[$0] }
            let composer = anchors.composer.map { proxy[$0] }
            ZStack(alignment: .topLeading) {
                if session.dayChipPicker != nil {
                    backdrop(composerFrame: composer)
                }
                if let picker = session.dayChipPicker, let chip, let composer {
                    FloatingDayPickerView(
                        picker: FloatingDayPickerView.binding(keeping: picker) {
                            session.dayChipPicker
                        } update: {
                            session.dayChipPicker = $0
                        },
                        availableHeight: composer.maxY - topMargin,
                        isKeyboardUp: !picker.hasHiddenKeyboard,
                        onHideKeyboard: session.hideKeyboardForDayChipPicker,
                        onChoose: session.chooseDayChipPickerDay,
                        onClose: session.closeDayChipPickerRestoringFocus
                    )
                        .frame(width: min(composer.width, FloatingDayPickerLayout.maxWidth))
                        .padding(.leading, composer.minX)
                        // Covers the composer, for the most height for its month.
                        .frame(width: proxy.size.width, height: composer.maxY, alignment: .bottomLeading)
                        // From the chip's corner, in the picker's frame, which ends at the composer's bottom.
                        .transition(FloatingDayPickerView.transition(
                            growingFrom: CGPoint(x: chip.minX, y: chip.maxY),
                            in: CGSize(width: proxy.size.width, height: composer.maxY)
                        ))
                }
            }
            .animation(FloatingDayPickerView.appearanceAnimation, value: session.dayChipPicker == nil)
        }
        .coordinateSpace(.named(coordinateSpaceName))
    }

    // MARK: - UI Components
    /// Takes every touch outside the picker, so a touch on the list or the composer, chip included, only closes the
    /// picker. Keyboard input isn't a touch, so typing still reaches the name field.
    private func backdrop(composerFrame: CGRect?) -> some View {
        Color.clear
            .contentShape(.rect)
            .ignoresSafeArea()
            .gesture(backdropDrag(composerFrame: composerFrame))
    }

    // MARK: - Gestures
    /// Closes the picker on any touch; a drag from the composer that would dismiss it there dismisses it too.
    private func backdropDrag(composerFrame: CGRect?) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpaceName))
            .onEnded { value in
                if let composerFrame, composerFrame.contains(value.startLocation), value.dismissesComposer {
                    // The composer goes too, so the keyboard isn't brought back.
                    session.closeDayChipPicker()
                    session.requestDismissal()
                } else {
                    session.closeDayChipPickerRestoringFocus()
                }
            }
    }
}
