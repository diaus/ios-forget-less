import Foundation
import Testing
@testable import Domain

struct CalendarDayTests {
    // MARK: - Tests
    @Test(arguments: [
        // Already the 26th in GMT.
        (-4 * 3600, "2026-10-25T23:30:00-04:00", "2026-10-25"),
        // Still the 24th in GMT.
        (2 * 3600, "2026-10-25T00:30:00+02:00", "2026-10-25"),
        // Already next year in GMT.
        (-4 * 3600, "2026-12-31T23:59:00-04:00", "2026-12-31"),
    ])
    func aMomentFallsOnItsLocalYearMonthDayAsGMTMidnight(
        secondsFromGMT: Int,
        moment: String,
        yearMonthDay: String
    ) throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: secondsFromGMT)!

        let day = calendar.day(containing: try Date(moment, strategy: .iso8601))

        #expect(day == (try Date("\(yearMonthDay)T00:00:00Z", strategy: .iso8601)))
    }
}
