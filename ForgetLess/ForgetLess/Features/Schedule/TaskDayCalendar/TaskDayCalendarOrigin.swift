import CoreGraphics

/// Where a Task's row was tapped to open its floating Day calendar, in the screen's coordinates.
struct TaskDayCalendarOrigin {
    let row: CGRect
    let tap: CGPoint
}
