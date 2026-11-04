import Domain
import Foundation

/// The Day picker's choice of a Day to move to.
struct DayPickerState {
    var isVisible = false
    private(set) var today: Date
    /// What the Day it confirms is for.
    let target: DayChoiceTarget
    private let openedDay: Date
    /// `nil` while nothing is chosen.
    private(set) var chosenDay: Date?

    /// Opens on `day`, the Day of `target`, or with nothing chosen when `day` is before Today.
    init(day: Date, today: Date, target: DayChoiceTarget) {
        self.openedDay = day
        self.today = today
        self.target = target
        self.chosenDay = day.canBePlanned(today: today) ? day : nil
    }

    /// The Day to move to: `nil` while nothing is chosen, or when the chosen Day is the Day it opened on.
    var dayToMove: Date? {
        chosenDay == openedDay ? nil : chosenDay
    }

    func canChoose(_ day: Date) -> Bool {
        day.canBePlanned(today: today)
    }

    /// Chooses `day`, unless it can't be chosen.
    mutating func choose(_ day: Date) {
        guard canChoose(day) else { return }
        chosenDay = day
    }

    /// Moves Today on, clearing a chosen Day it leaves in the past.
    mutating func update(today: Date) {
        self.today = today
        if let chosenDay, !canChoose(chosenDay) {
            self.chosenDay = nil
        }
    }
}
