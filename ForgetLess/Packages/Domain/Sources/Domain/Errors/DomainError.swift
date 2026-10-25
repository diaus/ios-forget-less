/// Rule errors raised by Domain functions and use cases. Carries codes only; the app maps them to user-facing text.
public enum DomainError: Error, Equatable, Sendable {
    /// A Task name was empty after trimming whitespace and newlines.
    case emptyName
}
