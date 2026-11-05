import Data
import Domain
import Foundation
import os
import WidgetKit

/// A write a widget intent makes to the App Group store (ADR 0005).
enum WidgetStoreWrite {
    /// Runs `write` on the Task with `taskID`, then reloads every widget. Does nothing when `taskID` names no Task's ID
    /// or the app hasn't created the store yet. A failure is logged to `logger` after `failureMessage`.
    static func run(
        taskID: String,
        logger: Logger,
        failureMessage: String,
        _ write: (_ repository: any TodoTaskRepository, _ id: UUID) async throws -> Void
    ) async {
        do {
            if let id = UUID(uuidString: taskID), let repository = try TodoTaskWriter.repository() {
                try await write(repository, id)
                // WidgetKit reloads only the tapped widget, so the others catch the write here (ADR 0005).
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            // A widget can't show an alert: the reload after the intent shows the Task as it still is.
            logger.error("\(failureMessage, privacy: .public): \(String(describing: error))")
        }
    }
}
