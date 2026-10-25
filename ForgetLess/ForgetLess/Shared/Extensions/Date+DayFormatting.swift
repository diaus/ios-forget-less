import Foundation

extension Date {
    // MARK: - Day Header
    /// `25 Oct · Today · Sunday`, `26 Oct · Tomorrow · Monday` or `27 Oct · Tuesday`, in the device locale. Today
    /// and Tomorrow are the only relative labels, and the short date follows the year rule.
    func dayHeader(today: Date, calendar: Calendar = .current) -> String {
        let relativeLabel: String? = switch dayChipCategory(today: today, calendar: calendar) {
        case .today: String(localized: .dayToday)
        case .tomorrow: String(localized: .dayTomorrow)
        case .weekday, .later, .past: nil
        }
        let parts = [
            shortDate(today: today, calendar: calendar),
            relativeLabel,
            weekday(calendar: calendar, capitalizationContext: .middleOfSentence),
        ]
        return parts.compactMap(\.self).joined(separator: " · ")
    }

    // MARK: - Short Date
    /// This Day as a short date in the device locale, such as `Nov 10` or `25 Oct`, with the year added when the
    /// Day isn't in Today's year.
    func shortDate(today: Date, calendar: Calendar = .current) -> String {
        let style = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day().month(.abbreviated)
        return formatted(shortDateShowsYear(today: today, calendar: calendar) ? style.year() : style)
    }

    /// The year rule: a short date shows its year only when the Day isn't in Today's year.
    func shortDateShowsYear(today: Date, calendar: Calendar = .current) -> Bool {
        calendar.component(.year, from: self) != calendar.component(.year, from: today)
    }

    // MARK: - Weekday
    /// The wide weekday name in the device locale, such as `Sunday`.
    func weekday(calendar: Calendar = .current, capitalizationContext: FormatStyleCapitalizationContext) -> String {
        let style = Date.FormatStyle(
            calendar: calendar,
            timeZone: calendar.timeZone,
            capitalizationContext: capitalizationContext
        )
        return formatted(style.weekday(.wide))
    }
}
