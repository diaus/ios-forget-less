import Foundation

/// Stores Tasks.
public protocol TodoTaskRepository: Sendable {
    /// The Tasks planned for `day`, in no particular order.
    func tasks(on day: Date) async throws -> [TodoTask]
    /// The Tasks the Schedule lists on `today`, in no particular order: sent at once, then again after every change,
    /// until the consumer stops iterating. Throws when the first fetch fails; a later fetch that fails sends nothing.
    func scheduleTasks(today: Date) async throws -> AsyncStream<[TodoTask]>
    /// Creates an Incomplete Task at the end of `day`.
    func create(name: String, day: Date) async throws
    /// Gives the Task with `id` a new name; does nothing when no Task has `id`.
    func rename(id: UUID, name: String) async throws
    /// Makes the Task with `id` Complete on `today`, or Incomplete; does nothing when no Task has `id`.
    func setComplete(id: UUID, isComplete: Bool, today: Date) async throws
}
