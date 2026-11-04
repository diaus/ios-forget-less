import Data
import Domain
import FactoryKit
import Foundation
import Observation
import Utils

/// Drives the Schedule screen.
@MainActor @Observable
final class ScheduleViewModel {
    private(set) var today: Date
    private(set) var schedule: Schedule
    var composer: ComposerState
    /// The composer's Day chip calendar; `nil` while it's closed.
    var dayChipCalendar: FloatingDayCalendarState?
    /// The floating Day calendar opened from a Task's row; `nil` while it's closed.
    var taskDayCalendar: TaskDayCalendar?
    /// The Day picker's choice; `nil` once it has closed. Kept until then, so the sheet keeps its content as it goes.
    var dayPicker: DayPickerState?
    private(set) var dayPickerOrigin: DayPickerOrigin?
    /// How many Incomplete Tasks each Day holds; a Day with none has no entry.
    private(set) var incompleteTaskCountsByDay: [Date: Int] = [:]
    let composerOpenerFocus = ComposerOpenerFocus()
    /// The Day the list last asked to bring into view.
    private(set) var dayReveal: DayReveal?
    var errorMessage: String?
    /// Whether the Schedule lists Complete Tasks. Kept across launches.
    var showsComplete: Bool {
        didSet {
            UserDefaults.standard.showsComplete = showsComplete
            keptTasks.releaseAll()
            rebuildSchedule()
        }
    }
    /// Whether Tasks can be moved. Kept across launches.
    var movesTasks: Bool {
        didSet {
            UserDefaults.standard.movesTasks = movesTasks
        }
    }
    /// The Tasks the Schedule lists, with any move not yet confirmed by the store already made.
    private var tasks: [TodoTask] = []
    /// The Tasks last observed in the store.
    private var observedTasks: [TodoTask] = []
    let keptTasks = KeptTasks()

    @ObservationIgnored @Injected(\.todoTaskRepository) private var repository
    @ObservationIgnored @Injected(\.addTask) private var addTask
    @ObservationIgnored @Injected(\.renameTask) private var renameTask

    init() {
        let today = Date.today
        self.today = today
        self.schedule = Schedule(tasks: [], today: today)
        self.composer = ComposerState(day: today)
        self.showsComplete = UserDefaults.standard.showsComplete
        self.movesTasks = UserDefaults.standard.movesTasks
        keptTasks.onRelease = { [weak self] in self?.rebuildSchedule() }
    }

    // MARK: - Loading
    /// Brings Today up to date.
    func refresh() {
        today = .today
        dayPicker?.update(today: today)
        dayChipCalendar?.update(today: today)
        taskDayCalendar?.calendar.update(today: today)
    }

    /// Keeps the Schedule up to date with the stored Tasks for the current Today, until the calling task is cancelled.
    func observeSchedule() async {
        do {
            for await tasks in try await repository.scheduleTasks(today: today) {
                observedTasks = tasks
                self.tasks = tasks
                // Its Task is gone, deleted elsewhere, so there's nothing left to Move.
                if let id = taskDayCalendar?.taskID, !tasks.contains(where: { $0.id == id }) {
                    taskDayCalendar = nil
                }
                rebuildSchedule()
            }
        } catch {
            errorMessage = error.userMessage
        }
    }

    // MARK: - Composer
    /// Shows the composer on `day`, to add a Task. VoiceOver goes back to `opener` when it closes.
    func showComposer(on day: Date, from opener: ComposerOpener) {
        composer.show(on: day)
        composerOpenerFocus.opener = opener
    }

    /// Shows the composer filled in with `task`, to edit it.
    func showComposer(editing task: TodoTask) {
        composer.show(editing: task)
        composerOpenerFocus.opener = .task(task.id)
    }

    /// Dismisses the composer, first asking whether to discard what was typed.
    func requestComposerDismissal() {
        if composer.hasChanges {
            composer.askToDiscard()
        } else {
            dismissComposer()
        }
    }

    /// Hides the composer and drops what's typed, so the next add starts blank. VoiceOver goes back to what showed it,
    /// and the list brings a Day stepped to into view.
    func dismissComposer() {
        closeDayChipCalendar()
        if composer.revealsDayOnDismiss {
            dayReveal = DayReveal(day: composer.day)
        }
        let editedTaskID = composer.editedTask?.id
        composer.hide()
        composerOpenerFocus.returnToOpener()
        if let editedTaskID {
            restartGracePeriod(of: editedTaskID)
            rebuildSchedule()
        }
    }

    /// Steps the composer's Day one Day forward, or back, never before Today; an edited Task moves to the end of that
    /// Day at once. Returns whether the Day changed.
    @discardableResult
    func stepComposerDay(forward: Bool) -> Bool {
        let shownDay = composer.day
        guard let day = forward ? shownDay.nextDayToPlan(today: today) : shownDay.previousDayToPlan(today: today)
        else { return false }
        return changeComposerDay(to: day)
    }

    /// Sets the composer's Day to `day`, chosen from a calendar, as a step does. VoiceOver says an edited Task's new
    /// Day once its Move is saved. Returns whether the Day changed.
    @discardableResult
    func chooseComposerDay(_ day: Date) -> Bool {
        changeComposerDay(to: day, onSaved: dayAnnouncement(day))
    }

    /// Saves the typed name: adds a Task to the composer's Day and stays up for the next one, or renames the Task
    /// being edited and dismisses. Saves nothing when the typed name can't be saved.
    func submitComposer() {
        closeDayChipCalendar()
        guard composer.canSubmit else { return }
        let name = composer.taskName
        if let editedTask = composer.editedTask {
            write {
                try await self.renameTask(id: editedTask.id, name: name)
                postAnnouncement(.taskRenamed(name: name))
            }
            // Saved under the typed name, so dismissing now drops nothing.
            composer.editedTask?.name = name.trimmed
            dismissComposer()
            return
        }
        let day = composer.day
        // Cleared at once, so a second submit before the write lands adds nothing.
        composer.clearForNextTask(afterAddingTo: day)
        write {
            try await self.addTask(name: name, day: day)
            postAnnouncement(.taskAdded(name: name))
        } onFailure: {
            // Give the name back unless the user has started typing another.
            if self.composer.taskName.isEmpty {
                self.composer.taskName = name
            }
        }
    }

    // MARK: - Completion
    func toggleComplete(_ task: TodoTask) {
        let isComplete = !task.isComplete
        if isComplete && !showsComplete {
            keptTasks.keep(task.id, for: UserDefaults.standard.keptDuration)
        } else {
            // Stays kept, so no rebuild drops it before the Tasks observed hold it Incomplete.
            keptTasks.stopGracePeriod(of: task.id)
        }
        write { try await self.repository.setComplete(id: task.id, isComplete: isComplete, today: self.today) }
    }

    // MARK: - Moving
    /// Moves `task` to `destination`, or lists it where it was when the move rule refuses that.
    func move(_ task: TodoTask, to destination: MoveDestination) {
        move(task, to: destination) {}
    }

    /// Moves `task` to `destination`, and has VoiceOver say its new Day once the move is saved.
    func moveAnnouncingDay(_ task: TodoTask, to destination: MoveDestination) {
        move(task, to: destination, onSaved: dayAnnouncement(destination.day))
    }

    // MARK: - Deletion
    func delete(_ task: TodoTask) {
        write { try await self.repository.delete(id: task.id) }
    }

    // MARK: - Helpers
    /// Sets the composer's Day to `day`, which can be planned for; an edited Task moves to the end of it at once, and
    /// `onSaved` runs once that's saved. Returns whether the Day changed: never on the composer's own Day.
    @discardableResult
    private func changeComposerDay(to day: Date, onSaved: @escaping @MainActor () -> Void = {}) -> Bool {
        guard day != composer.day else { return false }
        if let task = composer.editedTask {
            guard schedule.canMove(task, toDay: day) else { return false }
            saveMove(task, to: tasks.destinationAtEnd(of: day, forTaskWithID: task.id), onSaved: onSaved, onFailure: {
                // Back to the Day the store holds, as the list is.
                if let stored = self.observedTasks.first(where: { $0.id == task.id }),
                   self.composer.editedTask?.id == task.id {
                    self.composer.day = stored.day
                }
            })
        }
        composer.step(to: day)
        return true
    }

    /// Moves `task` to `destination` and runs `onSaved` once the store has it, or lists it where it was when the
    /// move rule refuses that.
    private func move(_ task: TodoTask, to destination: MoveDestination, onSaved: @escaping @MainActor () -> Void) {
        guard schedule.canMove(task, to: destination) else {
            // Rebuilt all the same, so a list that already moved the row puts it back.
            rebuildSchedule()
            return
        }
        saveMove(task, to: destination, onSaved: onSaved)
    }

    /// Moves `task` to `destination`, which the move rule allows, and runs `onSaved` once the store has it, or
    /// `onFailure` once the Task is back where the store holds it.
    private func saveMove(
        _ task: TodoTask,
        to destination: MoveDestination,
        onSaved: @escaping @MainActor () -> Void = {},
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        // Moved at once, so the row stays where it was dropped while the write is in flight.
        tasks = tasks.movingTask(id: task.id, to: destination)
        rebuildSchedule()
        write {
            try await self.repository.move(id: task.id, to: destination)
            onSaved()
        } onFailure: {
            // Nothing was saved, so the store's last Tasks put the Task back.
            self.tasks = self.observedTasks
            self.rebuildSchedule()
            onFailure()
        }
    }

    /// Moves `task` to the end of `day` unless the move rule refuses it, and has VoiceOver say `day` once the Move is
    /// saved. Returns whether it moved.
    @discardableResult
    private func moveToEnd(_ task: TodoTask, of day: Date) -> Bool {
        guard schedule.canMove(task, toDay: day) else { return false }
        saveMove(task, to: tasks.destinationAtEnd(of: day, forTaskWithID: task.id), onSaved: dayAnnouncement(day))
        return true
    }

    /// Lists the Task with `id` by the usual rules again, once the Day picker or its row's calendar no longer has it.
    private func stopListing(_ id: UUID) {
        restartGracePeriod(of: id)
        rebuildSchedule()
    }

    /// Gives the Task with `id`, listed while the composer, the Day picker or its row's calendar had it, its grace
    /// period afresh when it's Complete and Complete Tasks are hidden, so it's seen before it leaves.
    private func restartGracePeriod(of id: UUID) {
        if !showsComplete, tasks.contains(where: { $0.id == id && $0.isComplete }) {
            keptTasks.keep(id, for: UserDefaults.standard.keptDuration)
        }
    }

    /// Has VoiceOver say `day`, named as it is now, when called: once a move to it is saved.
    private func dayAnnouncement(_ day: Date) -> @MainActor () -> Void {
        let dayName = day.relativeNameOrShortDate(today: today)
        return { postAnnouncement(dayName) }
    }

    private func rebuildSchedule() {
        // The edited Task, and the one the Day picker or a row's calendar moves, stay listed until what has them
        // closes, even past their grace period, so they're seen as they move.
        let listedTaskIDs = keptTasks.ids.union(
            [composer.editedTask?.id, dayPickerOrigin?.taskID, taskDayCalendar?.taskID].compactMap { $0 }
        )
        schedule = Schedule(tasks: tasks, today: today, showsComplete: showsComplete, keptTaskIDs: listedTaskIDs)
        incompleteTaskCountsByDay = tasks.incompleteTaskCountsByDay
    }

    /// Runs `operation`; on failure, runs `onFailure` and shows the error.
    private func write(
        _ operation: @escaping @MainActor () async throws -> Void,
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        Task {
            do {
                try await operation()
            } catch {
                onFailure()
                errorMessage = error.userMessage
            }
        }
    }
}

// In an extension, so the class's body stays within SwiftLint's length.
extension ScheduleViewModel {
    // MARK: - Task Day Calendar
    /// Opens the floating Day calendar on `task`'s Day, by its row tapped as `origin` says, to Move it to another.
    func showTaskDayCalendar(for task: TodoTask, from origin: TaskDayCalendarOrigin) {
        let calendar = FloatingDayCalendarState(today: today, day: task.day)
        taskDayCalendar = TaskDayCalendar(taskID: task.id, origin: origin, calendar: calendar)
    }

    /// Moves the Task to the end of `day`, unless it's there already or the calendar or the move rule refuses it.
    /// VoiceOver says the new Day once the Move is saved.
    func chooseTaskDayCalendarDay(_ day: Date) {
        // Checked before the calendar draws the choice, so a refused Move shows nothing chosen.
        guard let open = taskDayCalendar, !open.calendar.isClosing, open.calendar.canChoose(day),
              let task = tasks.first(where: { $0.id == open.taskID }),
              day == task.day || moveToEnd(task, of: day) else { return }
        taskDayCalendar?.calendar.choose(day)
    }

    func closeTaskDayCalendar() {
        guard let id = taskDayCalendar?.taskID else { return }
        taskDayCalendar = nil
        stopListing(id)
    }

    // MARK: - Day Picker
    /// Shows the Day picker on `day`, the Day of what `origin` names, to choose another for it.
    func showDayPicker(on day: Date, from origin: DayPickerOrigin) {
        dayPicker = DayPickerState(day: day, today: today)
        dayPickerOrigin = origin
        dayPicker?.isVisible = true
    }

    /// Shows the Day picker on the composer's Day, to step it to another.
    func showComposerDayPicker() {
        // Dropped here rather than left to the sheet, so the keyboard reliably goes down while it's open.
        composer.isNameFocused = false
        closeDayChipCalendar()
        showDayPicker(on: composer.day, from: .composer)
    }

    /// Closes the Day picker and acts on the chosen Day, unless it's the Day the picker opened on: a row's Task moves
    /// to the end of it, and the composer's Day steps to it. VoiceOver says the new Day once a Move is saved.
    func confirmDayPicker() {
        dayPicker?.isVisible = false
        guard let day = dayPicker?.dayToMove, let dayPickerOrigin else { return }
        switch dayPickerOrigin {
        case let .taskRow(id):
            guard let task = tasks.first(where: { $0.id == id }) else { return }
            moveToEnd(task, of: day)
        case .composer:
            chooseComposerDay(day)
        }
    }

    /// Ends the Day picker once its sheet has closed, however it closed. One opened from the composer gives the name
    /// field its focus back, and VoiceOver goes back to the Day chip, as when the Day chip calendar closes.
    func dayPickerDidClose() {
        if dayPickerOrigin == .composer {
            composer.returnFocusToDayChip(bringingBackKeyboard: true)
        }
        let id = dayPickerOrigin?.taskID
        dayPicker = nil
        dayPickerOrigin = nil
        if let id { stopListing(id) }
    }
}
