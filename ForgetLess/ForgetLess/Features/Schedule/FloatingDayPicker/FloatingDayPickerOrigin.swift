import CoreGraphics

/// Where a Task's row or the Overdue header was tapped to open the floating Day picker, in the screen's coordinates.
struct FloatingDayPickerOrigin {
    /// The tapped row, or the Overdue header within the rows' margins.
    let frame: CGRect
    let tap: CGPoint
}
