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
    /// The chip category of this Day, a local start of day, relative to `today`.
    func dayChipCategory(today: Date, calendar: Calendar = .current) -> DayChipCategory {
        // Two local starts of day are always a whole number of Days apart.
        let dayCount = calendar.dateComponents([.day], from: today, to: self).day!
        return switch dayCount {
        case ..<0: .past
        case 0: .today
        case 1: .tomorrow
        case ..<7: .weekday
        default: .later
        }
    }

    // MARK: - Label
    /// `Today`, `Tomorrow`, the weekday (`Sunday`), or the short date (`Nov 10`) with the year rule.
    func dayChipLabel(today: Date, calendar: Calendar = .current) -> String {
        switch dayChipCategory(today: today, calendar: calendar) {
        case .today: String(localized: .dayToday)
        case .tomorrow: String(localized: .dayTomorrow)
        // The weekday is the whole label, so it's capitalised as a sentence's first word.
        case .weekday: weekday(calendar: calendar, capitalizationContext: .beginningOfSentence)
        case .later, .past: shortDate(today: today, calendar: calendar)
        }
    }

    // MARK: - Colour
    /// Green Today, orange Tomorrow, light blue weekday, light grey later, red past.
    func dayChipColor(today: Date, calendar: Calendar = .current) -> Color {
        switch dayChipCategory(today: today, calendar: calendar) {
        case .today: Color(.dayChipToday)
        case .tomorrow: Color(.dayChipTomorrow)
        case .weekday: Color(.dayChipWeekday)
        case .later: Color(.dayChipLater)
        case .past: Color(.dayChipPast)
        }
    }
}
