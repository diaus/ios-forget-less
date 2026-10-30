import Foundation

/// Stores Tasks. Every `day` is 00:00 GMT.
public protocol TodoTaskRepository: Sendable {
    /// The Tasks planned for `day`, in no particular order.
    func tasks(on day: Date) async throws -> [TodoTask]
    /// The Tasks planned for `day` or any later Day, in no particular order.
    func tasks(onOrAfter day: Date) async throws -> [TodoTask]
    func create(_ task: TodoTask) async throws
}
