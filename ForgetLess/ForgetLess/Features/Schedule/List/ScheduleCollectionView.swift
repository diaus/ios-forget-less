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

    // MARK: - Headers
    /// The one of `sections` whose header band holds `point`, in content coordinates.
    func section(withHeaderAt point: CGPoint, among sections: [Int]) -> Int? {
        let kind = UICollectionView.elementKindSectionHeader
        return sections.first { section in
            let indexPath = IndexPath(item: 0, section: section)
            guard let header = layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath) else {
                return false
            }
            // Half a header's height either side, so a lifted row finds the band easily.
            let band = header.frame.insetBy(dx: 0, dy: -header.frame.height / 2)
            return band.minY...band.maxY ~= point.y
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
