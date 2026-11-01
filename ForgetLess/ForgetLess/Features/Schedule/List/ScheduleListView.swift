import Domain
import FactoryKit
import SwiftUI

/// The Schedule's list of Days and their Tasks.
struct ScheduleListView: UIViewRepresentable {
    @InjectedObservable(\.scheduleViewModel) private var vm
    /// The safe area the list's content clears, which a wrapped view doesn't get on its own.
    let safeAreaInsets: EdgeInsets
    /// Asks the owner to show the composer on a Day, to add a Task.
    let onAdd: (Date) -> Void
    /// Asks the owner to show the composer on a Task, to edit it.
    let onEdit: (TodoTask) -> Void

    func makeCoordinator() -> ScheduleListController {
        ScheduleListController(listView: self)
    }

    func makeUIView(context: Context) -> ScheduleCollectionView {
        context.coordinator.collectionView
    }

    func updateUIView(_ collectionView: ScheduleCollectionView, context: Context) {
        context.coordinator.listView = self
        // Read here, so SwiftUI updates the list when they change. Animated only when SwiftUI animates the change, as
        // its `List` did.
        context.coordinator.show(
            vm.schedule,
            today: vm.today,
            movesTasks: vm.movesTasks,
            animated: context.transaction.animation != nil
        )
        context.coordinator.reveal(vm.dayReveal)
        collectionView.targetContentInsets = UIEdgeInsets(
            top: safeAreaInsets.top,
            left: 0,
            // Room under the last row, so the floating "+" never covers it.
            bottom: safeAreaInsets.bottom + 88,
            right: 0
        )
    }
}
