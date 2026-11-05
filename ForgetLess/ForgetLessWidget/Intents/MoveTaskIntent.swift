import AppIntents
import Domain
import Foundation
import os

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// Moves a listed Task one step up or down from the widget's arrows, to a destination the timeline worked out (ADR
/// 0005).
struct MoveTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "widget.moveTask"
    // Only the widget's arrows run it, so Shortcuts and Siri don't offer it.
    static let isDiscoverable = false

    @Parameter(title: "widget.task")
    var taskID: String

    @Parameter(title: "widget.day")
    var day: Date

    @Parameter(title: "widget.afterTask")
    var afterTaskID: String?

    private static let logger = Logger(subsystem: "ForgetLess.Widget", category: "MoveTaskIntent")

    init() {}

    init(taskID: UUID, to destination: MoveDestination) {
        self.taskID = taskID.uuidString
        self.day = destination.day
        self.afterTaskID = destination.after?.uuidString
    }

    func perform() async throws -> some IntentResult {
        let destination = MoveDestination(day: day, after: afterTaskID.flatMap(UUID.init(uuidString:)))
        await WidgetStoreWrite.run(
            taskID: taskID, logger: Self.logger, failureMessage: "Could not move the Task"
        ) { repository, id in
            try await repository.move(id: id, to: destination)
        }
        return .result()
    }
}

// swiftlint:enable catalog_key_literal
