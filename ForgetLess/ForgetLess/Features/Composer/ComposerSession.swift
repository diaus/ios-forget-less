import Domain
import FactoryKit
import Foundation
import Observation
import Utils

/// Drives the composer: what it shows, the Task it adds or edits, and where focus and the list go when it closes.
@MainActor @Observable
final class ComposerSession {
    var composer: ComposerState
    /// The composer's Day chip picker; `nil` while it's closed.
    var dayChipPicker: FloatingDayPickerState?
    let openerFocus = ComposerOpenerFocus()
    /// The Day the list last asked to bring into view.
    private(set) var dayReveal: DayReveal?
    /// Runs once the composer no longer has the Task it edited.
    @ObservationIgnored var onStopEditing: @MainActor (UUID) -> Void = { _ in }
    @ObservationIgnored private var today: Date
    private let scheduleTasks: ScheduleTasks
    private let taskMoves: TaskMoves
    private let writes: ScheduleWrites

    @ObservationIgnored @Injected(\.addTask) private var addTask
    @ObservationIgnored @Injected(\.renameTask) private var renameTask

    init(today: Date, scheduleTasks: ScheduleTasks, taskMoves: TaskMoves, writes: ScheduleWrites) {
        self.today = today
        self.composer = ComposerState(day: today)
        self.scheduleTasks = scheduleTasks
        self.taskMoves = taskMoves
        self.writes = writes
    }

    // MARK: - Showing
    /// Shows the composer on `day`, to add a Task. VoiceOver goes back to `opener` when it closes.
    func show(on day: Date, from opener: ComposerOpener) {
        composer.show(on: day)
        openerFocus.opener = opener
    }

    /// Shows the composer filled in with `task`, to edit it.
    func show(editing task: TodoTask) {
        composer.show(editing: task)
        openerFocus.opener = .task(task.id)
    }

    /// Dismisses the composer, first asking whether to discard what was typed.
    func requestDismissal() {
        if composer.hasChanges {
            composer.askToDiscard()
        } else {
            dismiss()
        }
    }

    /// Hides the composer and drops what's typed, so the next add starts blank. VoiceOver goes back to what showed it,
    /// and the list brings a Day stepped to into view.
    func dismiss() {
        closeDayChipPicker()
        if composer.revealsDayOnDismiss {
            dayReveal = DayReveal(day: composer.day)
        }
        let editedTaskID = composer.editedTask?.id
        composer.hide()
        openerFocus.returnToOpener()
        if let editedTaskID {
            onStopEditing(editedTaskID)
        }
    }

    // MARK: - Today
    func update(today: Date) {
        self.today = today
        dayChipPicker?.update(today: today)
    }

    // MARK: - Editing
    /// Steps the composer's Day one Day forward, or back, never before Today; an edited Task moves to the end of that
    /// Day at once. Returns whether the Day changed.
    @discardableResult
    func stepDay(forward: Bool) -> Bool {
        let shownDay = composer.day
        guard let day = forward ? shownDay.nextDayToPlan(today: today) : shownDay.previousDayToPlan(today: today)
        else { return false }
        return changeDay(to: day)
    }

    /// Steps the composer's Day to `day` unless the move rule refuses it; nothing changes when it's on `day` already.
    /// VoiceOver says an edited Task's new Day once its Move is saved. Returns whether the composer is on `day` now.
    func choose(_ day: Date) -> Bool {
        day == composer.day || changeDay(to: day, onSaved: day.moveAnnouncement(today: today))
    }

    /// Saves the typed name: adds a Task to the composer's Day and stays up for the next one, or renames the Task
    /// being edited and dismisses. Saves nothing when the typed name can't be saved.
    func submit() {
        closeDayChipPicker()
        let name = composer.taskName
        guard let savedName = TodoTask.savedName(from: name) else { return }
        if let editedTask = composer.editedTask {
            submitRename(of: editedTask, to: name, savedName: savedName)
        } else {
            submitAdd(name)
        }
    }

    // MARK: - Day Chip Picker
    /// Opens the Day chip picker on the composer's Day, or closes it when it's open.
    func toggleDayChipPicker() {
        if dayChipPicker == nil {
            dayChipPicker = FloatingDayPickerState(today: today, day: composer.day)
        } else {
            closeDayChipPicker()
        }
    }

    /// Closes the Day chip picker, leaving focus to whatever closes it.
    func closeDayChipPicker() {
        dayChipPicker = nil
    }

    /// Closes the Day chip picker back to the composer: the keyboard it hid comes back, and VoiceOver goes to the Day
    /// chip rather than wherever the vanished picker leaves it.
    func closeDayChipPickerRestoringFocus() {
        let hasHiddenKeyboard = dayChipPicker?.hasHiddenKeyboard ?? false
        closeDayChipPicker()
        composer.returnFocusToDayChip(bringingBackKeyboard: hasHiddenKeyboard)
    }

    /// Takes the keyboard down to make room for the Day chip picker, and keeps it down until the picker closes, so
    /// the picker never bounces as it refits.
    func hideKeyboardForDayChipPicker() {
        dayChipPicker?.recordHiddenKeyboard()
        composer.isNameFocused = false
    }

    /// Sets the composer to `day` as a step does, unless the Day chip picker is closed or closing, or it or the move
    /// rule refuses `day`. VoiceOver says an edited Task's new Day once its Move is saved.
    func chooseDayChipPickerDay(_ day: Date) {
        guard let picker = dayChipPicker, picker.takesChoice(of: day), choose(day) else { return }
        dayChipPicker?.choose(day)
    }

    // MARK: - Helpers
    /// Renames `editedTask` to `name`, which saves as `savedName`, and dismisses.
    private func submitRename(of editedTask: TodoTask, to name: String, savedName: String) {
        writes.run {
            try await self.renameTask(id: editedTask.id, name: name)
            postAnnouncement(.taskRenamed(name: name))
        }
        // Saved under the typed name, so dismissing now drops nothing.
        composer.editedTask?.name = savedName
        dismiss()
    }

    /// Adds a Task named `name` to the composer's Day, and clears the composer for the next one.
    private func submitAdd(_ name: String) {
        let day = composer.day
        // Cleared at once, so a second submit before the write lands adds nothing.
        composer.clearForNextTask(afterAddingTo: day)
        writes.run {
            try await self.addTask(name: name, day: day)
            postAnnouncement(.taskAdded(name: name))
        } onFailure: {
            // Give the name back unless the user has started typing another.
            if self.composer.taskName.isEmpty {
                self.composer.taskName = name
            }
        }
    }

    /// Sets the composer's Day to `day`, which can be planned for; an edited Task moves to the end of it at once, and
    /// `onSaved` runs once that's saved. Returns whether the Day changed: never on the composer's own Day.
    @discardableResult
    private func changeDay(to day: Date, onSaved: @escaping @MainActor () -> Void = {}) -> Bool {
        guard day != composer.day else { return false }
        if let task = composer.editedTask {
            let moved = taskMoves.moveToEnd(task, of: day, onSaved: onSaved) {
                // Back to the Day the store holds, as the list is.
                if let stored = self.scheduleTasks.task(withID: task.id), self.composer.editedTask?.id == task.id {
                    self.composer.day = stored.day
                }
            }
            guard moved else { return false }
        }
        composer.step(to: day)
        return true
    }
}
