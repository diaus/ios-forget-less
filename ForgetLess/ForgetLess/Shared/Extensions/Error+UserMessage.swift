import Domain
import Foundation

extension Error {
    /// The text the user sees for this error.
    var userMessage: String {
        switch self as? DomainError {
        case .emptyName: String(localized: .errorEmptyName)
        case nil: String(localized: .errorUnexpected)
        }
    }
}
