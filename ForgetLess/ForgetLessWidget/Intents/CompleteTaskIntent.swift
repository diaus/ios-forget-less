import AppIntents
import Domain
import Foundation
import os

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
        await WidgetStoreWrite.run(
            taskID: taskID, logger: Self.logger, failureMessage: "Could not make the Task Complete"
        ) { repository, id in
            try await repository.setComplete(id: id, isComplete: true, today: .today)
        }
        return .result()
    }
}

// swiftlint:enable catalog_key_literal
