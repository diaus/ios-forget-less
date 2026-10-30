import Domain
import SwiftUI

/// Which kind of Day the composer's Day chip shows, by the Day relative to Today.
enum DayChipCategory {
    case today
    case tomorrow
    /// After Tomorrow and before Today + 7.
    case weekday
    /// Today + 7 or later.
    case later
    /// Before Today.
    case past
}

extension Date {
    // MARK: - Category
    /// The chip category of this Day relative to `today`, both 00:00 GMT.
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
    /// `Today`, `Tomorrow`, the weekday (`Sunday`), or the short date (`Nov 10`) with the year rule.
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
    /// Green Today, orange Tomorrow, light blue weekday, light grey later, red past.
    func dayChipColor(today: Date) -> Color {
        switch dayChipCategory(today: today) {
        case .today: Color(.dayChipToday)
        case .tomorrow: Color(.dayChipTomorrow)
        case .weekday: Color(.dayChipWeekday)
        case .later: Color(.dayChipLater)
        case .past: Color(.dayChipPast)
        }
    }
}
