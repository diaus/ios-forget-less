import Foundation

/// Stores Tasks.
public protocol TodoTaskRepository: Sendable {
    /// The Tasks planned for `day`, in no particular order.
    func tasks(on day: Date) async throws -> [TodoTask]
    /// The Tasks planned for `day` or any later Day, in no particular order.
    func tasks(onOrAfter day: Date) async throws -> [TodoTask]
    /// The Incomplete Tasks planned for any Day before `day`, in no particular order.
    func incompleteTasks(before day: Date) async throws -> [TodoTask]
    /// The Tasks whose id is in `ids`, in no particular order; an id no Task has is skipped.
    func tasks(ids: Set<UUID>) async throws -> [TodoTask]
    /// Creates an Incomplete Task at the end of `day`.
    func create(name: String, day: Date) async throws
    /// Gives the Task with `id` a new name; does nothing when no Task has `id`.
    func rename(id: UUID, name: String) async throws
    /// Makes the Task with `id` Complete or Incomplete; does nothing when no Task has `id`.
    func setComplete(id: UUID, isComplete: Bool) async throws
}
