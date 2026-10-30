import Foundation

/// Loads the Schedule.
public struct LoadSchedule: Sendable {
    private let repository: any TodoTaskRepository

    public init(repository: any TodoTaskRepository) {
        self.repository = repository
    }

    /// `keepingOverdue` holds the Tasks completed from Overdue since the last refresh, which stay in it.
    public func callAsFunction(today: Date, keepingOverdue: Set<UUID>) async throws -> Schedule {
        let fromToday = try await repository.tasks(onOrAfter: today)
        let overdue = try await repository.incompleteTasks(before: today)
        let kept = try await repository.tasks(ids: keepingOverdue)
        // A kept Task made Incomplete again comes back from two queries.
        let tasksByID = Dictionary((fromToday + overdue + kept).map { ($0.id, $0) }) { first, _ in first }
        return Schedule(tasks: Array(tasksByID.values), today: today, keepingOverdue: keepingOverdue)
    }
}
