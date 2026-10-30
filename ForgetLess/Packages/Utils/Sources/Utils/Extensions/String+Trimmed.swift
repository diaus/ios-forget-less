import Foundation

public extension String {
    /// The receiver without leading and trailing whitespace and newlines.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
