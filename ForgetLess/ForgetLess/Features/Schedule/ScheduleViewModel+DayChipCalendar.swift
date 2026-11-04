import Foundation

// One file per Day chooser. Each gives its Day through the view model's shared Day chooser.
extension ScheduleViewModel {
    // MARK: - Day Chip Calendar
    /// Opens the Day chip calendar on the composer's Day, or closes it when it's open.
    func toggleDayChipCalendar() {
        if dayChipCalendar == nil {
            dayChipCalendar = FloatingDayCalendarState(today: today, day: composer.day)
        } else {
            closeDayChipCalendar()
        }
    }

    /// Closes the Day chip calendar, leaving focus to whatever closes it.
    func closeDayChipCalendar() {
        dayChipCalendar = nil
    }

    /// Closes the Day chip calendar back to the composer: the keyboard it hid comes back, and VoiceOver goes to the Day
    /// chip rather than wherever the vanished calendar leaves it.
    func closeDayChipCalendarRestoringFocus() {
        let hasHiddenKeyboard = dayChipCalendar?.hasHiddenKeyboard ?? false
        closeDayChipCalendar()
        composer.returnFocusToDayChip(bringingBackKeyboard: hasHiddenKeyboard)
    }

    /// Takes the keyboard down to make room for the Day chip calendar, and keeps it down until the calendar closes, so
    /// the calendar never bounces as it refits.
    func hideKeyboardForDayChipCalendar() {
        dayChipCalendar?.recordHiddenKeyboard()
        composer.isNameFocused = false
    }

    /// Sets the composer to `day` as a step does, unless the Day chip calendar or the move rule refuses it. VoiceOver
    /// says an edited Task's new Day once its Move is saved.
    func chooseDayChipCalendarDay(_ day: Date) {
        guard choose(day, in: dayChipCalendar, for: .composer) else { return }
        dayChipCalendar?.choose(day)
    }
}
