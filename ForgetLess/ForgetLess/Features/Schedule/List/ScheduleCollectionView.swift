import UIKit

/// The Schedule's collection view, which takes SwiftUI's safe area through `targetContentInsets`.
final class ScheduleCollectionView: UICollectionView {
    /// The insets the content needs, as SwiftUI measures them.
    var targetContentInsets: UIEdgeInsets = .zero {
        didSet {
            if targetContentInsets != oldValue {
                applyContentInsets()
            }
        }
    }
    private var lastAdjustedTop: CGFloat = 0

    // MARK: - Insets
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        applyContentInsets()
    }

    override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        // A list resting at the top stays there, under the bar, as its insets arrive.
        if contentOffset.y <= -lastAdjustedTop + 0.5 {
            contentOffset.y = -adjustedContentInset.top
        }
        lastAdjustedTop = adjustedContentInset.top
    }

    // MARK: - Moving
    /// Where a lifted row centred on `point`, in content coordinates, lands: in the section whose header is the nearest
    /// above it, after that section's rows above it. `nil` above the first header.
    /// - Parameter current: Where the lifted row's gap is now.
    func moveTarget(at point: CGPoint, from current: IndexPath) -> IndexPath? {
        guard let section = section(withHeaderAbove: point) else { return nil }
        // Asked of the layout, which places the other rows where they show mid-move; the collection view's own
        // `layoutAttributesForItem(at:)` still gives where they were before the lift. The gap never counts.
        let rowsAbove = (0..<numberOfItems(inSection: section)).filter { item in
            let indexPath = IndexPath(item: item, section: section)
            guard indexPath != current, let row = collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
                return false
            }
            return row.frame.midY < point.y
        }
        return IndexPath(item: rowsAbove.count, section: section)
    }

    /// The section whose header is the nearest above `point`, in content coordinates: the section a row at `point` sits
    /// in. `nil` above the first header.
    private func section(withHeaderAbove point: CGPoint) -> Int? {
        let kind = UICollectionView.elementKindSectionHeader
        // A header counts as above once the point passes its middle, so a row sliding over it changes section halfway.
        return (0..<numberOfSections).last { section in
            let indexPath = IndexPath(item: 0, section: section)
            guard let header = layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath) else {
                return false
            }
            return header.frame.midY <= point.y
        }
    }

    // MARK: - Helpers
    private func applyContentInsets() {
        // The scroll view keeps adjusting for UIKit's own safe area (`.automatic`), and only the rest is added here.
        // With `.never` and the full insets instead, UIKit hands the window's safe area to each cell under the status
        // bar or home indicator, and on iOS 18 that cell's content keeps a layout shifted by half of it after it
        // scrolls away.
        let top = max(0, targetContentInsets.top - safeAreaInsets.top)
        contentInset = UIEdgeInsets(
            top: top,
            left: 0,
            bottom: max(0, targetContentInsets.bottom - safeAreaInsets.bottom),
            right: 0
        )
        // The scroll indicator starts under the bar, as the content does.
        verticalScrollIndicatorInsets.top = top
    }
}
