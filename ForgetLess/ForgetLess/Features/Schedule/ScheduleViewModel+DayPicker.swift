import Foundation

// One file per Day chooser. Each gives its Day through the view model's shared Day chooser.
extension ScheduleViewModel {
    // MARK: - Day Picker
    /// Shows the Day picker on `day`, the Day of `target`, to choose another for it.
    func showDayPicker(on day: Date, for target: DayChoiceTarget) {
        dayPicker = DayPickerState(day: day, today: today, target: target)
        dayPicker?.isVisible = true
    }

    /// Shows the Day picker on the composer's Day, to step it to another.
    func showComposerDayPicker() {
        // Dropped here rather than left to the sheet, so the keyboard reliably goes down while it's open.
        composerSession.composer.isNameFocused = false
        composerSession.closeDayChipCalendar()
        showDayPicker(on: composerSession.composer.day, for: .composer)
    }

    /// Closes the Day picker and acts on the chosen Day, unless it's the Day the picker opened on: a row's Task moves
    /// to the end of it, and the composer's Day steps to it. VoiceOver says the new Day once a Move is saved.
    func confirmDayPicker() {
        dayPicker?.isVisible = false
        guard let dayPicker, let day = dayPicker.dayToMove else { return }
        choose(day, for: dayPicker.target)
    }

    /// Ends the Day picker once its sheet has closed, however it closed. One opened from the composer gives the name
    /// field its focus back, and VoiceOver goes back to the Day chip, as when the Day chip calendar closes.
    func dayPickerDidClose() {
        let target = dayPicker?.target
        if target == .composer {
            composerSession.composer.returnFocusToDayChip(bringingBackKeyboard: true)
        }
        dayPicker = nil
        if let id = target?.taskID { stopListing(id) }
    }
}
