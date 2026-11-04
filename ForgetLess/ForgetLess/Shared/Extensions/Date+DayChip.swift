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
        switch relativeDay(today: today) {
        case .beforeToday: .past
        case .today: .today
        case .tomorrow: .tomorrow
        case .later: dayCount(from: today) < Date.daysPerWeek ? .weekday : .later
        }
    }

    // MARK: - Label
    func dayChipLabel(today: Date) -> String {
        if let relativeName = relativeName(today: today) {
            return relativeName
        }
        // The weekday is the whole label, so it's capitalised as a sentence's first word.
        return dayChipCategory(today: today) == .weekday
            ? weekday(capitalizationContext: .beginningOfSentence)
            : shortDate(today: today)
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
