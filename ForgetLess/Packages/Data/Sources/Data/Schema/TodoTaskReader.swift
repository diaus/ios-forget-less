import Domain

/// The widget's read access to the App Group store the app writes (ADR 0003).
public enum TodoTaskReader {
    /// A fresh read-only repository, opened once per request so a long-lived widget process sees the app's latest
    /// save rather than what an earlier read left in its context. nil until the app has created the store.
    public static func repository() throws -> (any TodoTaskRepository)? {
        try ForgetLessModelContainer.makeReaderInAppGroup().map { TodoTaskRepositoryLive(modelContainer: $0) }
    }
}
