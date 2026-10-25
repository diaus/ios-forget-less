import Foundation

/// The name rule for a Task: the name is stored trimmed of surrounding whitespace and newlines, and must not be
/// empty after trimming. There is no length limit.
public func validatedTaskName(_ name: String) throws(DomainError) -> String {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { throw .emptyName }
    return trimmed
}
