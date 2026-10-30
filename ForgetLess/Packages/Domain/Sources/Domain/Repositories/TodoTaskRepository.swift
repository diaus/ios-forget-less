import Foundation

/// Stores Tasks.
public protocol TodoTaskRepository: Sendable {
    /// The Tasks planned for `day`, in no particular order.
    func tasks(on day: Date) async throws -> [TodoTask]
    /// The Tasks planned for `day` or any later Day, in no particular order.
    func tasks(onOrAfter day: Date) async throws -> [TodoTask]
    func create(_ task: TodoTask) async throws
    /// Makes the Task with `id` Complete or Incomplete; does nothing when no Task has `id`.
    func setComplete(id: UUID, isComplete: Bool) async throws
}
