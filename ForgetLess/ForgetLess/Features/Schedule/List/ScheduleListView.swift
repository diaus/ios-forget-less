import Domain
import FactoryKit
import SwiftUI

/// The Schedule's list of Days and their Tasks.
struct ScheduleListView: UIViewRepresentable {
    @InjectedObservable(\.scheduleViewModel) private var vm
    /// The safe area the list's content clears, which a wrapped view doesn't get on its own.
    let safeAreaInsets: EdgeInsets

    func makeCoordinator() -> ScheduleListController {
        ScheduleListController()
    }

    func makeUIView(context: Context) -> ScheduleCollectionView {
        context.coordinator.collectionView
    }

    func updateUIView(_ collectionView: ScheduleCollectionView, context: Context) {
        // Read here, so SwiftUI updates the list when they change. Animated only when SwiftUI animates the change, as
        // its `List` did.
        context.coordinator.show(
            vm.scheduleTasks.schedule,
            today: vm.today,
            movesTasks: vm.movesTasks,
            animated: context.transaction.animation != nil
        )
        context.coordinator.reveal(vm.dayReveal)
        context.coordinator.highlightRow(of: vm.taskDayCalendar?.taskID)
        collectionView.targetContentInsets = UIEdgeInsets(
            top: safeAreaInsets.top,
            left: 0,
            // Room under the last row, so the floating "+" never covers it.
            bottom: safeAreaInsets.bottom + 88,
            right: 0
        )
    }
}
