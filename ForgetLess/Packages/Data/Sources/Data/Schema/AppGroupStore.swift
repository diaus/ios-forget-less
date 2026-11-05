import Domain

/// The widget's access to the App Group store the app creates (ADRs 0003 and 0005).
public enum AppGroupStore {
    /// A fresh repository, opened once per request so a long-lived widget process starts from the app's latest save
    /// rather than what an earlier request left in its context. Read-only unless `writable`, which only the Tasks the
    /// widget makes Complete and Moves need. nil until the app has created the store.
    public static func repository(writable: Bool) throws -> (any TodoTaskRepository)? {
        try ForgetLessModelContainer.makeExisting(at: ForgetLessStoreLocation.appGroupStoreURL(), allowsSave: writable)
            .map { TodoTaskRepositoryLive(modelContainer: $0) }
    }
}
