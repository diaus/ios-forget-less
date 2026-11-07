import Domain
import Foundation

/// The sheet Day picker's choice of a Day to move to, or for the list to go to.
struct SheetDayPickerState {
    var isVisible = false
    private(set) var today: Date
    /// What the Day it confirms is for.
    let target: DayChoiceTarget
    /// Whether it opened while the Schedule listed History, so any Day can be chosen.
    let showsHistory: Bool
    private let openedDay: Date
    /// `nil` while nothing is chosen.
    private(set) var chosenDay: Date?

    /// How many months it offers from Today's on, and in History at least as many before it.
    private static let monthCount = 60

    /// Opens on `day`, the Day of `target`, or with nothing chosen when `day` can't be chosen.
    init(day: Date, today: Date, target: DayChoiceTarget, showsHistory: Bool) {
        self.openedDay = day
        self.today = today
        self.target = target
        self.showsHistory = showsHistory
        self.chosenDay = day.canBeChosen(today: today, showsHistory: showsHistory) ? day : nil
    }

    /// The Day it gives its target: `nil` while nothing is chosen, or when the chosen Day is the Day it opened on.
    var newDay: Date? {
        chosenDay == openedDay ? nil : chosenDay
    }

    /// The months it offers, as how many months each is after Today's month: in History, from one that holds the Day
    /// it opened on.
    var monthOffsets: Range<Int> {
        let firstMonthOffset = showsHistory ? min(-Self.monthCount, openedDay.monthCount(from: today)) : 0
        return firstMonthOffset..<Self.monthCount
    }

    func canChoose(_ day: Date) -> Bool {
        day.canBeChosen(today: today, showsHistory: showsHistory)
    }

    /// Chooses `day`, unless it can't be chosen.
    mutating func choose(_ day: Date) {
        guard canChoose(day) else { return }
        chosenDay = day
    }

    /// Moves Today on, clearing a chosen Day it leaves where it can't be chosen.
    mutating func update(today: Date) {
        self.today = today
        if let chosenDay, !canChoose(chosenDay) {
            self.chosenDay = nil
        }
    }
}
