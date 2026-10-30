/// Broken Domain rules; the app turns them into user-facing text.
public enum DomainError: Error, Equatable, Sendable {
    /// A Task name was blank.
    case emptyName
}
