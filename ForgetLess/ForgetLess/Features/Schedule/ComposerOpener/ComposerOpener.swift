import Foundation

/// What showed the composer: a "+", or a Task's row.
nonisolated enum ComposerOpener: Hashable {
    case floating
    case day(Date)
    case task(UUID)
}
