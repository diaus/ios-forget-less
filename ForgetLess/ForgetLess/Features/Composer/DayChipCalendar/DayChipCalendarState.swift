import Domain
import Foundation

/// The Day chip calendar's month and the Day it shows chosen.
struct DayChipCalendarState {
    private(set) var today: Date
    /// The composer's Day.
    private(set) var chipDay: Date
    /// The month shown, as how many months it's after Today's month.
    private(set) var monthOffset: Int
    /// Whether a Day has been chosen, so the calendar is about to close.
    private(set) var isClosing = false
    /// Whether the calendar took the keyboard down to make room, so closing it brings the keyboard back.
    private(set) var hasHiddenKeyboard = false

    init(today: Date, chipDay: Date) {
        self.today = today
        self.chipDay = chipDay
        // Never on a month before Today's, where nothing can be chosen.
        self.monthOffset = max(chipDay.monthCount(from: today), 0)
    }

    /// The chip's Day, or `nil` when it can't be chosen.
    var chosenDay: Date? {
        canChoose(chipDay) ? chipDay : nil
    }

    /// The nearest Days, one tap away from any month.
    var buttonDays: [Date] {
        (0..<3).map(today.addingDays)
    }

    func canChoose(_ day: Date) -> Bool {
        day.canBePlanned(today: today)
    }

    /// Makes `day` the chip's Day, unless it can't be chosen or a Day already was. Returns whether it did.
    @discardableResult
    mutating func choose(_ day: Date) -> Bool {
        // The calendar closes a moment after a choice, and a second tap in that moment changes nothing.
        guard !isClosing, canChoose(day) else { return false }
        chipDay = day
        isClosing = true
        return true
    }

    mutating func recordHiddenKeyboard() {
        hasHiddenKeyboard = true
    }

    /// Shows the month `monthOffset` months after Today's, or Today's month for one before it.
    mutating func page(to monthOffset: Int) {
        self.monthOffset = max(monthOffset, 0)
    }

    /// Shows the month `monthCount` months on from the one shown, unless it's before Today's. Returns whether it did.
    @discardableResult
    mutating func page(by monthCount: Int) -> Bool {
        guard monthOffset + monthCount >= 0 else { return false }
        monthOffset += monthCount
        return true
    }

    /// Moves Today on, keeping the month shown unless Today's month is now past it.
    mutating func update(today: Date) {
        let monthCount = today.monthCount(from: self.today)
        self.today = today
        page(to: monthOffset - monthCount)
    }
}
