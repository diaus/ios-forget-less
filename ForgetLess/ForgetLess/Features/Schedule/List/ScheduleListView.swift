import Domain
import SwiftUI

/// The Schedule's list of Days and their Tasks.
struct ScheduleListView: UIViewRepresentable {
    let schedule: Schedule
    let today: Date
    let composerOpenerFocus: ComposerOpenerFocus
    /// The safe area the list's content clears, which a wrapped view doesn't get on its own.
    let safeAreaInsets: EdgeInsets
    /// Asks the owner to show the composer on a Day, to add a Task.
    let onAdd: (Date) -> Void
    /// Asks the owner to show the composer on a Task, to rename it.
    let onRename: (TodoTask) -> Void
    /// Deletes a Task the user has confirmed.
    let onDelete: (TodoTask) -> Void

    func makeCoordinator() -> ScheduleListController {
        ScheduleListController(listView: self)
    }

    func makeUIView(context: Context) -> ScheduleCollectionView {
        context.coordinator.collectionView
    }

    func updateUIView(_ collectionView: ScheduleCollectionView, context: Context) {
        context.coordinator.listView = self
        // Animated only when SwiftUI animates the change, as its `List` did.
        context.coordinator.show(schedule, today: today, animated: context.transaction.animation != nil)
        collectionView.targetContentInsets = UIEdgeInsets(
            top: safeAreaInsets.top,
            left: 0,
            // Room under the last row, so the floating "+" never covers it.
            bottom: safeAreaInsets.bottom + 88,
            right: 0
        )
    }
}
