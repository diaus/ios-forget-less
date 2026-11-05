import Domain
import UIKit

extension UIAlertController {
    /// Asks whether to delete `task`, from its row `cell`, and runs `onDelete` once the user confirms.
    static func taskDeletionConfirmation(
        of task: TodoTask,
        from cell: UIView,
        onDelete: @escaping @MainActor () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: String(localized: .taskDeleteConfirmation(name: task.name)),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: String(localized: .taskDelete), style: .destructive) { _ in onDelete() })
        alert.addAction(UIAlertAction(title: String(localized: .taskDeleteCancel), style: .cancel))
        // Pointing at the row, as the dialog did when SwiftUI drew it.
        alert.popoverPresentationController?.sourceView = cell
        alert.popoverPresentationController?.sourceRect = cell.bounds
        return alert
    }
}
