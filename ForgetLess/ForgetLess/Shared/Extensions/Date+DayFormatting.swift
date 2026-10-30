import Domain
import Foundation

extension Date {
    // MARK: - Day Header
    /// This Day's title in its Schedule section header.
    func dayHeader(today: Date) -> String {
        let relativeLabel: String? = switch dayChipCategory(today: today) {
        case .today: String(localized: .dayToday)
        case .tomorrow: String(localized: .dayTomorrow)
        case .weekday, .later, .past: nil
        }
        let parts = [
            shortDate(today: today),
            relativeLabel,
            weekday(capitalizationContext: .middleOfSentence),
        ]
        return parts.compactMap(\.self).joined(separator: " · ")
    }

    // MARK: - Short Date
    /// This Day as a short date; `today` decides whether the year shows.
    func shortDate(today: Date) -> String {
        let style = Date.FormatStyle(calendar: .gmt, timeZone: .gmt).day().month(.abbreviated)
        return formatted(isInSameYear(as: today) ? style : style.year())
    }

    // MARK: - Weekday
    /// This Day's weekday name.
    func weekday(capitalizationContext: FormatStyleCapitalizationContext) -> String {
        let style = Date.FormatStyle(calendar: .gmt, timeZone: .gmt, capitalizationContext: capitalizationContext)
        return formatted(style.weekday(.wide))
    }
}
