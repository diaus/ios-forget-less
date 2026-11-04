import FactoryKit
import SwiftUI

/// The floating Day calendar opened from a Task's row, with what closes it on a touch anywhere else.
struct TaskDayCalendarOverlayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    /// What the list shows, between its bars, in the screen's coordinates.
    let listFrame: CGRect

    /// The calendar's height when nothing has to make room, which decides its side of the row. A guess at the default
    /// text size until the calendar has measured itself.
    @State private var fullHeight: CGFloat = 400

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let screenOrigin = proxy.frame(in: .global).origin
            ZStack(alignment: .topLeading) {
                if vm.taskDayCalendar != nil {
                    backdrop
                }
                if let open = vm.taskDayCalendar {
                    let row = open.origin.row.offsetBy(dx: -screenOrigin.x, dy: -screenOrigin.y)
                    let tap = CGPoint(x: open.origin.tap.x - screenOrigin.x, y: open.origin.tap.y - screenOrigin.y)
                    let space = listFrame.offsetBy(dx: -screenOrigin.x, dy: -screenOrigin.y)
                    let placement = TaskDayCalendarPlacement(row: row, tap: tap, space: space, fullHeight: fullHeight)
                    FloatingDayCalendarView(
                        calendar: binding(keeping: open.calendar),
                        availableHeight: placement.frame.height,
                        onFullHeightChange: { fullHeight = $0 },
                        onChoose: vm.chooseTaskDayCalendarDay,
                        onClose: vm.closeTaskDayCalendar
                    )
                    .frame(
                        width: placement.frame.width,
                        height: placement.frame.height,
                        alignment: placement.opensBelow ? .top : .bottom
                    )
                    .padding(.leading, placement.frame.minX)
                    .padding(.top, placement.frame.minY)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                    .transition(
                        .scale(scale: 0.1, anchor: unitPoint(tap, in: proxy.size)).combined(with: .opacity)
                    )
                }
            }
            .animation(.snappy(duration: 0.25), value: vm.taskDayCalendar == nil)
        }
        .ignoresSafeArea()
    }

    // MARK: - UI Components
    /// Takes every touch outside the calendar, so a touch on the list only closes the calendar, and never scrolls it.
    private var backdrop: some View {
        Color.clear
            .contentShape(.rect)
            .gesture(DragGesture(minimumDistance: 0).onEnded { _ in vm.closeTaskDayCalendar() })
    }

    // MARK: - Helpers
    /// The open calendar's state, or `calendar` once it has closed, while it animates out. A closed calendar takes
    /// no change.
    private func binding(keeping calendar: FloatingDayCalendarState) -> Binding<FloatingDayCalendarState> {
        Binding { vm.taskDayCalendar?.calendar ?? calendar } set: { vm.taskDayCalendar?.calendar = $0 }
    }

    private func unitPoint(_ point: CGPoint, in size: CGSize) -> UnitPoint {
        UnitPoint(x: point.x / max(size.width, 1), y: point.y / max(size.height, 1))
    }
}
