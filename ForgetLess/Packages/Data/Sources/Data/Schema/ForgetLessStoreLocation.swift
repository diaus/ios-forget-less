import Foundation

/// Where the on-disk store lives: the App Group container the app and the widget share (ADR 0003).
enum ForgetLessStoreLocation {
    /// The App Group the app and the widget share. Each target's `.entitlements` file lists this same identifier.
    static let appGroupIdentifier = "group.io.github.diaus.ForgetLess"

    /// The process isn't entitled to the App Group, so it has no container to open the store in.
    struct AppGroupUnavailable: Error {
        let identifier: String
    }

    /// The store in the App Group container, at the path and name SwiftData itself would pick there.
    static func appGroupStoreURL() throws -> URL {
        let fileManager = FileManager.default
        guard let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw AppGroupUnavailable(identifier: appGroupIdentifier)
        }
        return container.appending(path: "Library/Application Support/default.store")
    }
}
