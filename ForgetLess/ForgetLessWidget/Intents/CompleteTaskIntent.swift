import AppIntents
import Domain
import Foundation
import os

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// Makes a listed Task Complete from the widget's circle, or Incomplete again during the widget's Grace Period (ADR
/// 0005).
struct CompleteTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "widget.completeTask"
    // Only the widget's circle runs it, so Shortcuts and Siri don't offer it.
    static let isDiscoverable = false

    @Parameter(title: "widget.task")
    var taskID: String

    @Parameter(title: "widget.isComplete")
    var isComplete: Bool

    private static let logger = Logger(subsystem: "ForgetLess.Widget", category: "CompleteTaskIntent")

    init() {}

    init(taskID: UUID, isComplete: Bool) {
        self.taskID = taskID.uuidString
        self.isComplete = isComplete
    }

    func perform() async throws -> some IntentResult {
        let failureMessage = isComplete ? "Could not make the Task Complete" : "Could not make the Task Incomplete"
        await WidgetStoreWrite.run(
            taskID: taskID, logger: Self.logger, failureMessage: failureMessage
        ) { repository, id in
            try await repository.setComplete(id: id, isComplete: isComplete, now: .now)
        }
        return .result()
    }
}

// swiftlint:enable catalog_key_literal
