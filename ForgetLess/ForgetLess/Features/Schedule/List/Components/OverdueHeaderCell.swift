import UIKit

/// The Overdue section's header in the Schedule's list, which knows where it was last touched, for the floating Day
/// picker to grow from.
final class OverdueHeaderCell: UICollectionViewListCell {
    /// Where the last touch on the header began, in the window's coordinates.
    private(set) var lastTouchLocation: CGPoint?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == .touches {
            lastTouchLocation = convert(point, to: nil)
        }
        return super.hitTest(point, with: event)
    }
}
