import AppIntents
import Data
import Domain
import Foundation
import os
import WidgetKit

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// Makes a listed Task Complete from the widget's circle (ADR 0005).
struct CompleteTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "widget.completeTask"
    // Only the widget's circle runs it, so Shortcuts and Siri don't offer it.
    static let isDiscoverable = false

    @Parameter(title: "widget.task")
    var taskID: String

    private static let logger = Logger(subsystem: "ForgetLess.Widget", category: "CompleteTaskIntent")

    init() {}

    init(taskID: UUID) {
        self.taskID = taskID.uuidString
    }

    func perform() async throws -> some IntentResult {
        do {
            if let id = UUID(uuidString: taskID), let repository = try TodoTaskWriter.repository() {
                try await repository.setComplete(id: id, isComplete: true, today: .today)
                // WidgetKit reloads only the tapped widget, so the others catch the write here (ADR 0005).
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            // A widget can't show an alert: the reload after this shows the Task as it still is.
            Self.logger.error("Could not make the Task Complete: \(String(describing: error))")
        }
        return .result()
    }
}

// swiftlint:enable catalog_key_literal
