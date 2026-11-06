import Domain
import Foundation

// One file per Day chooser. Each gives its Day through the view model's shared Day chooser.
extension ScheduleViewModel {
    // MARK: - Floating Day Picker
    /// Opens the floating Day picker on `task`'s Day, by its row tapped as `origin` says, to Move it to another.
    func showFloatingDayPicker(for task: TodoTask, from origin: FloatingDayPickerOrigin) {
        let picker = FloatingDayPickerState(today: today, day: task.day)
        floatingDayPicker = FloatingDayPickerPresentation(taskID: task.id, origin: origin, picker: picker)
    }

    /// Moves the Task to the end of `day`, unless it's there already, the picker is closing, or it or the move rule
    /// refuses `day`. VoiceOver says the new Day once the Move is saved.
    func chooseFloatingDayPickerDay(_ day: Date) {
        guard let open = floatingDayPicker, open.picker.takesChoice(of: day), choose(day, for: .task(open.taskID))
        else { return }
        floatingDayPicker?.picker.choose(day)
    }

    func closeFloatingDayPicker() {
        guard let id = floatingDayPicker?.taskID else { return }
        floatingDayPicker = nil
        stopListing(id)
    }
}
