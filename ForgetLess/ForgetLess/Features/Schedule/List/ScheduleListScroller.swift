import Domain
import UIKit

/// Scrolls the Schedule's list where the view model asks, once per request, and holds the Days on screen still while
/// Days are added or removed above them.
final class ScheduleListScroller {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ScheduleListContent.Section, TodoTask.ID>

    private let collectionView: ScheduleCollectionView
    /// The reveal last carried out, so each is carried out once.
    private var lastReveal: DayReveal?
    /// The jump last carried out, so each is carried out once.
    private var lastHistoryJump: HistoryJump?

    init(collectionView: ScheduleCollectionView) {
        self.collectionView = collectionView
    }

    // MARK: - Requests
    /// Brings the last Task of `reveal`'s Day into view, unless `reveal` was carried out before.
    /// - Parameter shown: What the list shows.
    func reveal(_ reveal: DayReveal?, in shown: Snapshot) {
        guard let reveal, reveal != lastReveal else { return }
        lastReveal = reveal
        let section = ScheduleListContent.Section.day(reveal.day)
        // Asking a snapshot for a section it lacks raises an exception.
        guard let sectionIndex = shown.indexOfSection(section) else { return }
        let taskCount = shown.numberOfItems(inSection: section)
        guard taskCount > 0 else { return }
        collectionView.scrollToShowRow(at: IndexPath(item: taskCount - 1, section: sectionIndex))
    }

    /// Scrolls, without animation, where `jump` asks, on `today`, unless `jump` was carried out before.
    /// - Parameter shown: What the list shows.
    func jump(_ jump: HistoryJump?, today: Date, in shown: Snapshot) {
        guard let jump, jump != lastHistoryJump else { return }
        lastHistoryJump = jump
        let target: JumpTarget = switch jump.destination {
        case .yesterday: .header(.day(today.addingDays(-1)))
        case .top: .top
        }
        // The Days the jump lands among are laid out at an estimated height until they show, so the first scroll can
        // land off its target, and the next starts from Days laid out at their real heights.
        for _ in 0...Self.jumpRetryLimit {
            guard let offsetY = offsetY(reaching: target, in: shown),
                  abs(offsetY - collectionView.contentOffset.y) > 0.5 else { return }
            collectionView.scroll(toOffsetY: offsetY)
        }
    }

    // MARK: - Holding Still
    /// Runs `apply`, which shows `next` in place of `shown`, keeping the first section on screen that `next` still
    /// lists where it is on screen, unless `holdsStill` is false.
    func apply(_ next: Snapshot, over shown: Snapshot, holdingStill holdsStill: Bool, by apply: () -> Void) {
        let anchor = holdsStill ? self.anchor(from: shown, keptIn: next) : nil
        apply()
        guard let anchor, let section = next.indexOfSection(anchor.section) else { return }
        collectionView.placeHeader(ofSection: section, atOffset: anchor.headerOffset)
    }

    // MARK: - Helpers
    /// Where a jump scrolls to.
    private enum JumpTarget {
        /// A section's header at the top.
        case header(ScheduleListContent.Section)
        case top
    }

    /// Enough to land a jump that a few Days laid out where it lands have moved, without chasing a list that keeps
    /// changing.
    private static let jumpRetryLimit = 3

    /// The content offset that reaches `target`, or `nil` when `shown` doesn't list its section.
    private func offsetY(reaching target: JumpTarget, in shown: Snapshot) -> CGFloat? {
        switch target {
        case let .header(section):
            shown.indexOfSection(section).flatMap(collectionView.offsetYPuttingHeaderAtTop(ofSection:))
        case .top:
            collectionView.topOffsetY
        }
    }

    /// A section on screen and its header's offset from the list's top edge.
    private struct Anchor {
        let section: ScheduleListContent.Section
        let headerOffset: CGFloat
    }

    /// The first section on screen in `shown` that `next` still lists, or `nil` when it lists none of them.
    private func anchor(from shown: Snapshot, keptIn next: Snapshot) -> Anchor? {
        let sections = shown.sectionIdentifiers
        for index in collectionView.sectionsOnScreen where sections.indices.contains(index) {
            guard next.indexOfSection(sections[index]) != nil,
                  let offset = collectionView.headerOffset(ofSection: index) else { continue }
            return Anchor(section: sections[index], headerOffset: offset)
        }
        return nil
    }
}
