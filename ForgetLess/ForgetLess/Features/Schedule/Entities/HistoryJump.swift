import Foundation

/// A request for the Schedule's list to scroll to where History starts reading, once it shows History, or to its top,
/// once it no longer does. Each request is new, so the same jump twice in a row scrolls twice.
struct HistoryJump: Equatable {
    /// Where the list scrolls to.
    enum Destination: Equatable {
        /// Yesterday's header at the top, with Today below it.
        case yesterday
        /// The top of the list: Overdue, or else Today.
        case top
    }

    let destination: Destination
    private let id = UUID()

    init(to destination: Destination) {
        self.destination = destination
    }
}
