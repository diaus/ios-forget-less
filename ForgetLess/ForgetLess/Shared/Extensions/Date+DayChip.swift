import Domain
import SwiftUI

/// The kind of Day a Day chip shows, relative to Today.
enum DayChipCategory {
    case today
    case tomorrow
    /// Near enough to name by its weekday.
    case weekday
    /// Too far to name by its weekday.
    case later
    /// Before Today.
    case past
}

extension Date {
    // MARK: - Category
    func dayChipCategory(today: Date) -> DayChipCategory {
        switch dayCount(from: today) {
        case ..<0: .past
        case 0: .today
        case 1: .tomorrow
        case ..<7: .weekday
        default: .later
        }
    }

    // MARK: - Label
    func dayChipLabel(today: Date) -> String {
        switch dayChipCategory(today: today) {
        case .today: String(localized: .dayToday)
        case .tomorrow: String(localized: .dayTomorrow)
        // The weekday is the whole label, so it's capitalised as a sentence's first word.
        case .weekday: weekday(capitalizationContext: .beginningOfSentence)
        case .later, .past: shortDate(today: today)
        }
    }

    // MARK: - Colour
    func dayChipColor(today: Date) -> Color {
        switch dayChipCategory(today: today) {
        case .today: Color(.dayChipToday)
        case .tomorrow: Color(.dayChipTomorrow)
        case .weekday: Color(.dayChipWeekday)
        case .later: Color(.dayChipLater)
        case .past: Color(.overdueDay)
        }
    }
}
