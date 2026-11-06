import Foundation

/// Stores Tasks.
public protocol TodoTaskRepository: Sendable {
    /// The Tasks the Schedule lists on `today`, in order of Day, then position within it: sent at once, then again
    /// after every change, until the consumer stops iterating. Throws when the first fetch fails; a later fetch that
    /// fails sends nothing.
    func scheduleTasks(today: Date) async throws -> AsyncStream<[TodoTask]>
    /// The Incomplete Tasks whose Day is from `firstDay` through `lastDay`, with no lower bound when `firstDay` is nil,
    /// in order of Day, then position within it.
    func incompleteTasks(from firstDay: Date?, through lastDay: Date) async throws -> [TodoTask]
    /// Creates an Incomplete Task at the end of `day`.
    func create(name: String, day: Date) async throws
    /// Gives the Task with `id` a new name; does nothing when no Task has `id`.
    func rename(id: UUID, name: String) async throws
    /// Makes the Task with `id` Complete on `today`, or Incomplete; does nothing when no Task has `id`.
    func setComplete(id: UUID, isComplete: Bool, today: Date) async throws
    /// Moves the Task with `id` to `destination`, or to the end of `destination`'s Day when the Task it names isn't on
    /// it, and leaves the Day it left as it was; does nothing when no Task has `id`.
    func move(id: UUID, to destination: MoveDestination) async throws
    /// Moves the Tasks with `ids`, in that order, to the top of `day` in one save, and leaves the Days they left as
    /// they were; skips IDs with no Task, and does nothing when no Task has any of them.
    func move(ids: [UUID], toStartOf day: Date) async throws
    /// Deletes the Task with `id` for good; does nothing when no Task has `id`.
    func delete(id: UUID) async throws
}
