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
        switch relativeDay(today: today) {
        case .today: String(localized: .dayToday)
        case .tomorrow: String(localized: .dayTomorrow)
        case .beforeToday, .yesterday, .later: nil
        }
    }

    /// This Day in a word when it has one, or else its short date.
    func relativeNameOrShortDate(today: Date) -> String {
        relativeName(today: today) ?? shortDate(today: today)
    }

    // MARK: - Short Date
    /// This Day as a short date; `today` decides whether the year shows.
    func shortDate(today: Date) -> String {
        formatted(Date.dayStyle.day().month(.abbreviated), today: today)
    }

    // MARK: - Full Date
    /// This Day in full, weekday and year included, as VoiceOver reads it.
    var fullDate: String {
        formatted(Date.FormatStyle(date: .complete, time: .omitted, calendar: .gmt, timeZone: .gmt))
    }

    // MARK: - Weekday
    /// This Day's weekday name.
    func weekday(capitalizationContext: FormatStyleCapitalizationContext) -> String {
        var style = Date.dayStyle
        style.capitalizationContext = capitalizationContext
        return formatted(style.weekday(.wide))
    }

    /// This Day's weekday as a short name, as a column of weeks is headed.
    var shortWeekday: String {
        formatted(Date.dayStyle.weekday(.abbreviated))
    }

    // MARK: - Month
    /// The name of this Day's month; `today` decides whether the year shows.
    func monthName(today: Date) -> String {
        formatted(Date.dayStyle.month(.wide), today: today)
    }

    /// This Day's number within its month.
    var dayOfMonth: String {
        formatted(Date.dayStyle.day())
    }

    // MARK: - Helpers
    /// The style every Day is formatted from (ADR 0001).
    private static var dayStyle: Date.FormatStyle {
        Date.FormatStyle(calendar: .gmt, timeZone: .gmt)
    }

    /// This Day in `style`, with the year added when it isn't `today`'s.
    private func formatted(_ style: Date.FormatStyle, today: Date) -> String {
        formatted(isInSameYear(as: today) ? style : style.year())
    }
}
