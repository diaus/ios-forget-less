import Domain
import Foundation

extension Date {
    // MARK: - Day Header
    /// This Day's title in its Schedule section header.
    func dayHeader(today: Date) -> String {
        let parts = [
            shortDate(today: today),
            relativeName(today: today),
            weekday(capitalizationContext: .middleOfSentence),
        ]
        return parts.compactMap(\.self).joined(separator: " · ")
    }

    // MARK: - Relative Name
    /// This Day in a word when it has one: Today, Tomorrow, or `nil` for any other Day.
    func relativeName(today: Date) -> String? {
        switch dayChipCategory(today: today) {
        case .today: String(localized: .dayToday)
        case .tomorrow: String(localized: .dayTomorrow)
        case .weekday, .later, .past: nil
        }
    }

    /// This Day in a word when it has one, or else its short date.
    func relativeNameOrShortDate(today: Date) -> String {
        relativeName(today: today) ?? shortDate(today: today)
    }

    // MARK: - Short Date
    /// This Day as a short date; `today` decides whether the year shows.
    func shortDate(today: Date) -> String {
        formatted(Date.FormatStyle(calendar: .gmt, timeZone: .gmt).day().month(.abbreviated), today: today)
    }

    /// This Day's short date, led by its weekday's short name.
    func weekdayAndShortDate(today: Date) -> String {
        "\(shortWeekday) \(shortDate(today: today))"
    }

    // MARK: - Weekday
    /// This Day's weekday name.
    func weekday(capitalizationContext: FormatStyleCapitalizationContext) -> String {
        let style = Date.FormatStyle(calendar: .gmt, timeZone: .gmt, capitalizationContext: capitalizationContext)
        return formatted(style.weekday(.wide))
    }

    /// This Day's weekday as a short name, as a column of weeks is headed.
    var shortWeekday: String {
        formatted(Date.FormatStyle(calendar: .gmt, timeZone: .gmt).weekday(.abbreviated))
    }

    // MARK: - Month
    /// The name of this Day's month; `today` decides whether the year shows.
    func monthName(today: Date) -> String {
        formatted(Date.FormatStyle(calendar: .gmt, timeZone: .gmt).month(.wide), today: today)
    }

    /// This Day's number within its month.
    var dayOfMonth: String {
        formatted(Date.FormatStyle(calendar: .gmt, timeZone: .gmt).day())
    }

    // MARK: - Helpers
    /// This Day in `style`, with the year added when it isn't `today`'s.
    private func formatted(_ style: Date.FormatStyle, today: Date) -> String {
        formatted(isInSameYear(as: today) ? style : style.year())
    }
}
