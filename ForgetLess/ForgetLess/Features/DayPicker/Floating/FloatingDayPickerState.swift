import Domain
import Foundation

/// The floating Day picker's month and the Day it shows chosen.
struct FloatingDayPickerState {
    private(set) var today: Date
    /// The Day it's for: the composer's, or the Task's it opened from.
    private(set) var day: Date
    /// The month shown, as how many months it's after Today's month.
    private(set) var monthOffset: Int
    /// Whether a Day has been chosen, so the picker is about to close.
    private(set) var isClosing = false
    /// Whether the picker took the keyboard down to make room, so closing it brings the keyboard back.
    private(set) var hasHiddenKeyboard = false

    init(today: Date, day: Date) {
        self.today = today
        self.day = day
        // Never on a month before Today's, where nothing can be chosen.
        self.monthOffset = max(day.monthCount(from: today), 0)
    }

    /// Its Day, or `nil` when it can't be chosen.
    var chosenDay: Date? {
        canChoose(day) ? day : nil
    }

    /// The nearest Days, one tap away from any month.
    var buttonDays: [Date] {
        (0..<3).map(today.addingDays)
    }

    func canChoose(_ day: Date) -> Bool {
        day.canBePlanned(today: today)
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
