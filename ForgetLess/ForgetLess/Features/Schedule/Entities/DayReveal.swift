import Foundation

/// A request for the Schedule's list to bring the last Task of a Day into view. Each request is new, so asking for the
/// same Day twice scrolls twice.
struct DayReveal: Equatable {
    let day: Date
    private let id = UUID()

    init(day: Date) {
        self.day = day
    }
}
