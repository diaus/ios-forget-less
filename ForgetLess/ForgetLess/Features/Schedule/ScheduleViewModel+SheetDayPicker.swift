import Foundation

// One file per Day chooser. Each gives its Day through the view model's shared Day chooser.
extension ScheduleViewModel {
    // MARK: - Sheet Day Picker
    /// Shows the sheet Day picker on `day`, the Day of `target`, to choose another for it.
    func showSheetDayPicker(on day: Date, for target: DayChoiceTarget) {
        sheetDayPicker = SheetDayPickerState(day: day, today: today, target: target)
        sheetDayPicker?.isVisible = true
    }

    /// Shows the sheet Day picker on the composer's Day, to step it to another.
    func showComposerSheetDayPicker() {
        // Dropped here rather than left to the sheet, so the keyboard reliably goes down while it's open.
        composerSession.composer.isNameFocused = false
        composerSession.closeDayChipPicker()
        showSheetDayPicker(on: composerSession.composer.day, for: .composer)
    }

    /// Closes the sheet Day picker and acts on the chosen Day, unless it's the Day the picker opened on: a row's Task
    /// moves to the end of it, and the composer's Day steps to it. VoiceOver says the new Day once a Move is saved.
    func confirmSheetDayPicker() {
        sheetDayPicker?.isVisible = false
        guard let sheetDayPicker, let day = sheetDayPicker.dayToMove else { return }
        choose(day, for: sheetDayPicker.target)
    }

    /// Ends the sheet Day picker once its sheet has closed, however it closed. One opened from the composer gives the
    /// name field its focus back, and VoiceOver goes back to the Day chip, as when the Day chip picker closes.
    func sheetDayPickerDidClose() {
        let target = sheetDayPicker?.target
        if target == .composer {
            composerSession.composer.returnFocusToDayChip(bringingBackKeyboard: true)
        }
        sheetDayPicker = nil
        if let id = target?.taskID { stopListing(id) }
    }
}
