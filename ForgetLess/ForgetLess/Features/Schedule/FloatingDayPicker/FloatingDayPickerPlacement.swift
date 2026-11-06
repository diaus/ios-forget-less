import CoreGraphics

/// Where the floating Day picker opened from a Task's row sits, beside the row so the row stays in view.
struct FloatingDayPickerPlacement {
    /// What the picker fits in: its width, and all the height its side of the row has.
    let frame: CGRect
    /// Whether it's under the row, at the top of `frame`, rather than above the row, at its bottom.
    let opensBelow: Bool

    /// Kept clear between the picker and the row, and the edges of the space.
    private static let margin: CGFloat = 8

    /// Places the picker by the `row` tapped at `tap`, within `space`, with as much of its `fullHeight` as there's
    /// room for, preferring under the row.
    init(row: CGRect, tap: CGPoint, space: CGRect, fullHeight: CGFloat) {
        let heightBelow = space.maxY - Self.margin - (row.maxY + Self.margin)
        let heightAbove = row.minY - Self.margin - (space.minY + Self.margin)
        let opensBelow = heightBelow >= fullHeight || (heightAbove < fullHeight && heightBelow >= heightAbove)
        let height = max(opensBelow ? heightBelow : heightAbove, 0)
        let width = min(row.width, FloatingDayPickerLayout.maxWidth)
        // Centred on the tap, but never past the row's edges, which keep the list's margins.
        let minX = min(max(tap.x - width / 2, row.minX), row.maxX - width)
        let minY = opensBelow ? row.maxY + Self.margin : row.minY - Self.margin - height
        frame = CGRect(x: minX, y: minY, width: width, height: height)
        self.opensBelow = opensBelow
    }
}
