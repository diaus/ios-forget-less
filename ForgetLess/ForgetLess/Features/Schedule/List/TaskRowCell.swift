import UIKit

/// A Task's row in the Schedule's list, which knows when its handle is touched, so only the handle starts a move.
final class TaskRowCell: UICollectionViewListCell {
    /// Where to look for a finger on the handle.
    private weak var touchEvent: UIEvent?

    // MARK: - Handle
    var isHandleTouched: Bool {
        let touches = touchEvent?.allTouches ?? []
        return touches.contains { touch in
            // Outside its content the row holds only the handle and, while swiped, its actions, which never start a
            // move.
            guard let view = touch.view, view.isDescendant(of: self), !view.isDescendant(of: contentView) else {
                return false
            }
            return touch.phase != .ended && touch.phase != .cancelled
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == .touches {
            touchEvent = event
        }
        return super.hitTest(point, with: event)
    }

    // MARK: - VoiceOver
    override func layoutSubviews() {
        super.layoutSubviews()
        // VoiceOver can't drag the handle: it moves a Task with the circle's actions.
        for subview in subviews where subview !== contentView {
            subview.accessibilityElementsHidden = true
        }
    }
}
