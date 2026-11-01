import UIKit

extension UISwipeActionsConfiguration {
    // MARK: - Task Row Actions
    /// A Task row's trailing swipe actions: Delete on the outer edge, then Choose Day.
    static func taskRowActions(
        onDelete: @escaping () -> Void,
        onChooseDay: @escaping () -> Void
    ) -> UISwipeActionsConfiguration {
        let delete = action(
            symbol: "trash", label: String(localized: .taskDelete),
            color: UIColor(resource: .deleteAction), handler: onDelete
        )
        // Offered whether Move Tasks is on or off: like the composer's Day chip, it never moves a Task by accident.
        let chooseDay = action(
            symbol: "calendar", label: String(localized: .taskChooseDay),
            color: UIColor(resource: .chooseDayAction), handler: onChooseDay
        )
        // The first action is the outermost.
        let configuration = UISwipeActionsConfiguration(actions: [delete, chooseDay])
        // No full swipe: deleting always asks first.
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    // MARK: - Helpers
    private static func action(
        symbol: String,
        label: String,
        color: UIColor,
        handler: @escaping () -> Void
    ) -> UIContextualAction {
        // No title, so only the icon shows; VoiceOver reads the icon's label.
        let action = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            handler()
            completion(true)
        }
        let image = UIImage(systemName: symbol)
        image?.accessibilityLabel = label
        action.image = image
        action.backgroundColor = color
        return action
    }
}
