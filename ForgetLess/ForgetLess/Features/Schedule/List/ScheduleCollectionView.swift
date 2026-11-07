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

    // MARK: - Scrolling
    /// Scrolls, animated, just far enough to show the row at `indexPath` in full; does nothing when it shows already.
    func scrollToShowRow(at indexPath: IndexPath) {
        // Laid out first, so a row the last snapshot just placed has its frame.
        layoutIfNeeded()
        guard let row = layoutAttributesForItem(at: indexPath)?.frame else { return }
        let insets = adjustedContentInset
        let offsetY: CGFloat
        if row.minY < contentOffset.y + insets.top {
            offsetY = row.minY - insets.top
        } else if row.maxY > contentOffset.y + bounds.height - insets.bottom {
            offsetY = row.maxY - bounds.height + insets.bottom
        } else {
            return
        }
        scrollAnimated(toOffsetY: offsetY)
    }

    /// The content offset that puts the header of `section` at the top, or as near as the content allows; `nil` when
    /// it has none.
    func offsetYPuttingHeaderAtTop(ofSection section: Int) -> CGFloat? {
        // Laid out first, so a section the last snapshot just placed has its frame.
        layoutIfNeeded()
        return headerFrame(ofSection: section).map { clampedOffsetY($0.minY - adjustedContentInset.top) }
    }

    var topOffsetY: CGFloat {
        -adjustedContentInset.top
    }

    /// Scrolls, animated, to `offsetY`, or as near as the content allows.
    func scrollAnimated(toOffsetY offsetY: CGFloat) {
        setContentOffset(CGPoint(x: contentOffset.x, y: clampedOffsetY(offsetY)), animated: true)
    }

    /// Scrolls, without animation, to `offsetY`, or as near as the content allows.
    func scroll(toOffsetY offsetY: CGFloat) {
        setContentOffset(CGPoint(x: contentOffset.x, y: clampedOffsetY(offsetY)), animated: false)
    }

    /// The first section the list shows below the bar's edge, or `nil` while nothing is listed.
    var sectionAtTop: Int? {
        let top = contentOffset.y + adjustedContentInset.top
        // Shown once its last row, or its header when it has none, is at least half below the edge, so a Day whose
        // header alone peeks out from under the bar doesn't count.
        return sectionsOnScreen.first { section in
            let rowCount = numberOfItems(inSection: section)
            let lastFrame = rowCount > 0
                ? layoutAttributesForItem(at: IndexPath(item: rowCount - 1, section: section))?.frame
                : headerFrame(ofSection: section)
            return lastFrame.map { $0.midY >= top } ?? false
        }
    }

    /// Whether the list shows within a screen of its top.
    var isNearTop: Bool {
        contentOffset.y + adjustedContentInset.top < bounds.height
    }

    // MARK: - Holding Still
    /// The sections with a header or row on screen, top first.
    var sectionsOnScreen: [Int] {
        let headers = indexPathsForVisibleSupplementaryElements(ofKind: Self.elementKindSectionHeader)
        return Set((headers + indexPathsForVisibleItems).map(\.section)).sorted()
    }

    /// How far the header of `section` is below the list's top edge, negative above it; `nil` when it has none.
    func headerOffset(ofSection section: Int) -> CGFloat? {
        headerFrame(ofSection: section).map { $0.minY - contentOffset.y }
    }

    /// Scrolls, without animation, so the header of `section` is `offset` below the list's top edge.
    func placeHeader(ofSection section: Int, atOffset offset: CGFloat) {
        // Laid out first, so a section the last snapshot just placed has its frame.
        layoutIfNeeded()
        if let header = headerFrame(ofSection: section) {
            contentOffset.y = header.minY - offset
        }
    }

    // MARK: - Headers
    /// The header of `section` on screen, within its rows' margins, though it spans past them, in the window's
    /// coordinates; `nil` while it's off screen or the section has no row.
    func headerFrameWithinRowMargins(ofSection section: Int) -> CGRect? {
        let indexPath = IndexPath(item: 0, section: section)
        guard let header = supplementaryView(forElementKind: Self.elementKindSectionHeader, at: indexPath),
              let firstRow = layoutAttributesForItem(at: indexPath) else { return nil }
        let headerFrame = header.convert(header.bounds, to: nil)
        let rowFrame = convert(firstRow.frame, to: nil)
        return CGRect(x: rowFrame.minX, y: headerFrame.minY, width: rowFrame.width, height: headerFrame.height)
    }

    /// Moves VoiceOver's focus to the header of `section`, when it's on screen.
    func moveVoiceOverFocusToHeader(ofSection section: Int) {
        // Laid out first, so a header the last scroll brought on screen is there.
        layoutIfNeeded()
        let indexPath = IndexPath(item: 0, section: section)
        if let header = supplementaryView(forElementKind: Self.elementKindSectionHeader, at: indexPath) {
            UIAccessibility.post(notification: .layoutChanged, argument: header)
        }
    }

    // MARK: - Helpers
    /// Where the header of `section` is laid out, in content coordinates; `nil` when it has none.
    private func headerFrame(ofSection section: Int) -> CGRect? {
        let indexPath = IndexPath(item: 0, section: section)
        return layoutAttributesForSupplementaryElement(ofKind: Self.elementKindSectionHeader, at: indexPath)?.frame
    }

    /// `offsetY`, or the nearest offset the content allows.
    private func clampedOffsetY(_ offsetY: CGFloat) -> CGFloat {
        let insets = adjustedContentInset
        let maxOffsetY = max(-insets.top, contentSize.height + insets.bottom - bounds.height)
        return min(max(offsetY, -insets.top), maxOffsetY)
    }

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
