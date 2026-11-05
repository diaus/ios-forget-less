import Domain

/// The widget's write access to the App Group store the app created, for the Tasks it makes Complete and Moves (ADR
/// 0005).
public enum TodoTaskWriter {
    /// A fresh repository, opened once per write so it starts from the app's latest save. nil until the app has
    /// created the store.
    public static func repository() throws -> (any TodoTaskRepository)? {
        try ForgetLessModelContainer.makeWriterInAppGroup().map { TodoTaskRepositoryLive(modelContainer: $0) }
    }
}
