import Domain
import Foundation

/// The floating Day picker's month and the Day it shows chosen.
struct FloatingDayPickerState {
    private(set) var today: Date
    /// The Day it's for: the composer's, or the Task's it opened from.
    private(set) var day: Date
    /// Whether it opened while the Schedule listed History, so any Day can be chosen and it pages back without limit.
    let showsHistory: Bool
    /// The month shown, as how many months it's after Today's month.
    private(set) var monthOffset: Int
    /// Whether a Day has been chosen, so the picker is about to close.
    private(set) var isClosing = false
    /// Whether the picker took the keyboard down to make room, so closing it brings the keyboard back.
    private(set) var hasHiddenKeyboard = false

    /// - Parameter firstWeekday: The weekday weeks start on, numbered as `Date.firstWeekday` is.
    init(today: Date, day: Date, showsHistory: Bool, firstWeekday: Int = Date.firstWeekday) {
        self.today = today
        self.day = day
        self.showsHistory = showsHistory
        let ownMonthOffset = day.monthCount(from: today)
        let ownMonth = DayPickerCalendar.Month(today: today, offset: ownMonthOffset, firstWeekday: firstWeekday)
        let ownMonthShowsDay = ownMonth.weeks(count: FloatingDayPickerLayout.weekCount).joined().contains(day)
        // A Day its own month's weeks cut off at the end falls in the next month's first week.
        self.monthOffset = ownMonthShowsDay ? ownMonthOffset : ownMonthOffset + 1
        // Outside History, never on a month before Today's, where nothing can be chosen.
        page(to: monthOffset)
    }

    // MARK: - Choosing
    /// Its Day, or `nil` when it can't be chosen.
    var chosenDay: Date? {
        canChoose(day) ? day : nil
    }

    /// The nearest Days, one tap away from any month.
    var buttonDays: [Date] {
        (0..<3).map(today.addingDays)
    }

    func canChoose(_ day: Date) -> Bool {
        day.canBeChosen(today: today, showsHistory: showsHistory)
    }

    /// Whether choosing `day` would make it its Day: `day` can be chosen, and no Day already was.
    func takesChoice(of day: Date) -> Bool {
        // The picker closes a moment after a choice, and a second tap in that moment changes nothing.
        !isClosing && canChoose(day)
    }

    /// Makes `day` its Day, unless it doesn't take that choice. Returns whether it did.
    @discardableResult
    mutating func choose(_ day: Date) -> Bool {
        guard takesChoice(of: day) else { return false }
        self.day = day
        isClosing = true
        return true
    }

    // MARK: - Keyboard
    mutating func recordHiddenKeyboard() {
        hasHiddenKeyboard = true
    }

    // MARK: - Paging
    /// Shows the month `monthOffset` months after Today's, or, outside History, Today's month for one before it.
    mutating func page(to monthOffset: Int) {
        self.monthOffset = canPage(to: monthOffset) ? monthOffset : 0
    }

    /// Shows the month `monthCount` months on from the one shown, unless it's before Today's outside History. Returns
    /// whether it did.
    @discardableResult
    mutating func page(by monthCount: Int) -> Bool {
        guard canPage(to: monthOffset + monthCount) else { return false }
        monthOffset += monthCount
        return true
    }

    /// Moves Today on, keeping the month shown unless, outside History, Today's month is now past it.
    mutating func update(today: Date) {
        let monthCount = today.monthCount(from: self.today)
        self.today = today
        page(to: monthOffset - monthCount)
    }

    // MARK: - Helpers
    private func canPage(to monthOffset: Int) -> Bool {
        showsHistory || monthOffset >= 0
    }
}
