import Domain
import Foundation

extension Date {
    // MARK: - Day Header
    /// `25 Oct · Today · Sunday`, `26 Oct · Tomorrow · Monday` or `27 Oct · Tuesday`, in the device locale. Today
    /// and Tomorrow are the only relative labels, and the short date follows the year rule.
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
    /// This Day as a short date in the device locale, such as `Nov 10` or `25 Oct`, with the year added when the
    /// Day isn't in Today's year.
    func shortDate(today: Date) -> String {
        let style = Date.FormatStyle(calendar: .gmt, timeZone: .gmt).day().month(.abbreviated)
        return formatted(isInSameYear(as: today) ? style : style.year())
    }

    // MARK: - Weekday
    /// The wide weekday name in the device locale, such as `Sunday`.
    func weekday(capitalizationContext: FormatStyleCapitalizationContext) -> String {
        let style = Date.FormatStyle(calendar: .gmt, timeZone: .gmt, capitalizationContext: capitalizationContext)
        return formatted(style.weekday(.wide))
    }
}
