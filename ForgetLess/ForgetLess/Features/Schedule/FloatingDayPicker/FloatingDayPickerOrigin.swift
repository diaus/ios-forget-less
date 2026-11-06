import CoreGraphics

/// Where a Task's row was tapped to open its floating Day picker, in the screen's coordinates.
struct FloatingDayPickerOrigin {
    let row: CGRect
    let tap: CGPoint
}
