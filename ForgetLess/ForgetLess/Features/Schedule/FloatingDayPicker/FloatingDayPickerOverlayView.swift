import FactoryKit
import SwiftUI

/// The floating Day picker opened from a Task's row or the Overdue header, with what closes it on a touch anywhere
/// else.
struct FloatingDayPickerOverlayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    /// What the list shows, between its bars, in the screen's coordinates.
    let listFrame: CGRect

    /// The picker's height when nothing has to make room, which decides its side of the row. A guess at the default
    /// text size until the picker has measured itself.
    @State private var fullHeight: CGFloat = 400

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let screenOrigin = proxy.frame(in: .global).origin
            ZStack(alignment: .topLeading) {
                if vm.floatingDayPicker != nil {
                    backdrop
                }
                if let open = vm.floatingDayPicker {
                    let row = open.origin.frame.offsetBy(dx: -screenOrigin.x, dy: -screenOrigin.y)
                    let tap = CGPoint(x: open.origin.tap.x - screenOrigin.x, y: open.origin.tap.y - screenOrigin.y)
                    let space = listFrame.offsetBy(dx: -screenOrigin.x, dy: -screenOrigin.y)
                    let placement = FloatingDayPickerPlacement(row: row, tap: tap, space: space, fullHeight: fullHeight)
                    FloatingDayPickerView(
                        picker: FloatingDayPickerView.binding(keeping: open.picker) {
                            vm.floatingDayPicker?.picker
                        } update: {
                            vm.floatingDayPicker?.picker = $0
                        },
                        availableHeight: placement.frame.height,
                        onFullHeightChange: { fullHeight = $0 },
                        onChoose: vm.chooseFloatingDayPickerDay,
                        onClose: vm.closeFloatingDayPicker
                    )
                    .frame(
                        width: placement.frame.width,
                        height: placement.frame.height,
                        alignment: placement.opensBelow ? .top : .bottom
                    )
                    .padding(.leading, placement.frame.minX)
                    .padding(.top, placement.frame.minY)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                    .transition(FloatingDayPickerView.transition(growingFrom: tap, in: proxy.size))
                }
            }
            .animation(FloatingDayPickerView.appearanceAnimation, value: vm.floatingDayPicker == nil)
        }
        .ignoresSafeArea()
    }

    // MARK: - UI Components
    /// Takes every touch outside the picker, so a touch on the list only closes the picker, and never scrolls it.
    private var backdrop: some View {
        Color.clear
            .contentShape(.rect)
            .gesture(DragGesture(minimumDistance: 0).onEnded { _ in vm.closeFloatingDayPicker() })
    }
}
