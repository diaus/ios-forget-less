import Domain
import Foundation

extension Error {
    /// The catalog text shown to the user for this error.
    var userMessage: String {
        switch self as? DomainError {
        case .emptyName: String(localized: .errorEmptyName)
        case nil: String(localized: .errorUnexpected)
        }
    }
}
