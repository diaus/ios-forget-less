import Domain
import Foundation

// One file per Day chooser. Each gives its Day through the view model's shared Day chooser.
extension ScheduleViewModel {
    // MARK: - Floating Day Picker
    /// Opens the floating Day picker on `task`'s Day, by its row tapped as `origin` says, to Move it to another.
    func showFloatingDayPicker(for task: TodoTask, from origin: FloatingDayPickerOrigin) {
        let picker = FloatingDayPickerState(today: today, day: task.day, showsHistory: showsHistory)
        floatingDayPicker = FloatingDayPickerPresentation(target: .task(task.id), origin: origin, picker: picker)
    }

    /// Opens the floating Day picker by the Overdue header tapped as `origin` says, with nothing chosen, to Move every
    /// Overdue Task to a Day. Does nothing while the sheet Day picker is up.
    func showOverdueFloatingDayPicker(from origin: FloatingDayPickerOrigin) {
        // The lift that ends the long press opening the sheet also reaches the header's button, as a tap.
        guard sheetDayPicker == nil else { return }
        // A Day before Today, which can't be chosen outside History, where alone Overdue is listed, so the picker opens
        // on Today's month with nothing chosen.
        let picker = FloatingDayPickerState(today: today, day: today.addingDays(-1), showsHistory: showsHistory)
        floatingDayPicker = FloatingDayPickerPresentation(target: .overdueTasks, origin: origin, picker: picker)
    }

    /// Moves what the picker is for to `day`, unless it's there already, the picker is closing, or it or the move rule
    /// refuses `day`. VoiceOver says the new Day once the Move is saved.
    func chooseFloatingDayPickerDay(_ day: Date) {
        guard let open = floatingDayPicker, open.picker.takesChoice(of: day), choose(day, for: open.target)
        else { return }
        floatingDayPicker?.picker.choose(day)
    }

    func closeFloatingDayPicker() {
        guard let target = floatingDayPicker?.target else { return }
        floatingDayPicker = nil
        if let id = target.taskID { stopListing(id) }
    }

    /// Closes the floating Day picker once what it Moves is gone: its Task, deleted elsewhere, or every Overdue Task,
    /// moved elsewhere.
    func closeFloatingDayPickerWithNothingToMove() {
        guard let open = floatingDayPicker else { return }
        let hasNothingToMove = switch open.target {
        // Going to a Day never opens it: only the sheet Day picker does.
        case .composer, .goToDay: false
        case let .task(id): scheduleTasks.task(withID: id) == nil
        // Not once a Day is chosen, which itself empties Overdue: the picker closes a moment later, so it's seen.
        case .overdueTasks: !open.picker.isClosing && scheduleTasks.schedule.overdueIncomplete.isEmpty
        }
        if hasNothingToMove {
            floatingDayPicker = nil
        }
    }
}
