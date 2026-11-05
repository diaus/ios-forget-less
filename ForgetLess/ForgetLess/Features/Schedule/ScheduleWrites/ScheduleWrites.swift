import Foundation
import Observation

/// Runs the Schedule's writes, and holds the message of the last failure, a write's or the store's, until it's shown.
@MainActor @Observable
final class ScheduleWrites {
    var errorMessage: String?

    /// Runs `operation`; on failure, runs `onFailure` and shows the error.
    func run(
        _ operation: @escaping @MainActor () async throws -> Void,
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        Task {
            do {
                try await operation()
            } catch {
                onFailure()
                errorMessage = error.userMessage
            }
        }
    }
}
