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
        months.first { $0.days.contains(day) }?.weeks.first { $0.contains(day) }.map(Row.week)
    }
}

private extension DayPickerCalendar.Month {
    /// This month's Days in rows of a week, `nil` for each cell before the 1st or after the last Day.
    var weeks: [[Date?]] {
        let cells = Array(repeating: nil, count: leadingBlankCount) + days.map(Optional.some)
        return stride(from: 0, to: cells.count, by: 7).map { start in
            let week = Array(cells[start..<min(start + 7, cells.count)])
            return week + Array(repeating: nil, count: 7 - week.count)
        }
    }
}
