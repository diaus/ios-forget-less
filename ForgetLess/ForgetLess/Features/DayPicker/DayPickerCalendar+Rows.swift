import Domain
import Foundation

extension DayPickerCalendar {
    /// A row of the Day picker's scrolling list.
    nonisolated enum Row: Hashable, Identifiable, Sendable {
        /// The header of the month that starts on this Day.
        case monthHeader(Date)
        /// Seven cells of a week, `nil` for each cell outside its month.
        case week([Date?])

        var id: Self { self }
    }

    /// Every month's header followed by its weeks, a row each, so the list can scroll to a week it hasn't drawn yet.
    var rows: [Row] {
        months.flatMap { month in [.monthHeader(month.firstDay)] + month.weeks.map(Row.week) }
    }

    /// The row of the week that holds `day`, or `nil` when no month shown holds it.
    func weekRow(containing day: Date) -> Row? {
        week(containing: day).map(Row.week)
    }
}
