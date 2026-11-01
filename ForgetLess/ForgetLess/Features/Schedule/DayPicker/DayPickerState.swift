import Domain
import Foundation

/// The Day picker's choice of a Day for the Task being moved.
struct DayPickerState {
    let task: TodoTask
    private(set) var today: Date
    /// `nil` while nothing is chosen.
    private(set) var chosenDay: Date?

    /// Opens on `task`'s Day, or with nothing chosen when the Task is Overdue.
    init(task: TodoTask, today: Date) {
        self.task = task
        self.today = today
        self.chosenDay = task.day.canBePlanned(today: today) ? task.day : nil
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

    /// The Day to move the Task to: `nil` while nothing is chosen, or when the chosen Day is the Task's own.
    var dayToMoveTo: Date? {
        chosenDay == task.day ? nil : chosenDay
    }
}
