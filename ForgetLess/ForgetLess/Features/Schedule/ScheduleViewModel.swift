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
    var composer: ComposerState
    /// The composer's Day chip calendar; `nil` while it's closed.
    var dayChipCalendar: FloatingDayCalendarState?
    /// The floating Day calendar opened from a Task's row; `nil` while it's closed.
    var taskDayCalendar: TaskDayCalendar?
    /// The Day picker's choice; `nil` once it has closed. Kept until then, so the sheet keeps its content as it goes.
    var dayPicker: DayPickerState?
    let composerOpenerFocus = ComposerOpenerFocus()
    /// The Day the list last asked to bring into view.
    private(set) var dayReveal: DayReveal?
    var errorMessage: String?
    /// Whether the Schedule lists Complete Tasks. Kept across launches.
    var showsComplete: Bool {
        didSet {
            UserDefaults.standard.showsComplete = showsComplete
            keptTasks.releaseAll()
            scheduleTasks.relist()
        }
    }
    /// Whether Tasks can be moved. Kept across launches.
    var movesTasks: Bool {
        didSet {
            UserDefaults.standard.movesTasks = movesTasks
        }
    }
    /// The Tasks the Schedule lists, with any Move not yet saved already made.
    private(set) var scheduleTasks: ScheduleTasks
    let keptTasks = KeptTasks()

    @ObservationIgnored @Injected(\.todoTaskRepository) private var repository
    @ObservationIgnored @Injected(\.addTask) private var addTask
    @ObservationIgnored @Injected(\.renameTask) private var renameTask

    init() {
        let today = Date.today
        self.today = today
        self.composer = ComposerState(day: today)
        self.showsComplete = UserDefaults.standard.showsComplete
        self.movesTasks = UserDefaults.standard.movesTasks
        self.scheduleTasks = ScheduleTasks(today: today)
        // Unowned: the view model holds the Tasks, so it outlives them.
        scheduleTasks.listing = { [unowned self] in listing }
        keptTasks.onRelease = { [weak self] in self?.scheduleTasks.relist() }
    }
}

// In an extension, so the class's body stays within SwiftLint's length.
extension ScheduleViewModel {
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
                // Its Task is gone, deleted elsewhere, so there's nothing left to Move.
                if let id = taskDayCalendar?.taskID, !tasks.contains(where: { $0.id == id }) {
                    taskDayCalendar = nil
                }
                scheduleTasks.observe(tasks)
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
            stopListing(editedTaskID)
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

    /// Saves the typed name: adds a Task to the composer's Day and stays up for the next one, or renames the Task
    /// being edited and dismisses. Saves nothing when the typed name can't be saved.
    func submitComposer() {
        closeDayChipCalendar()
        let name = composer.taskName
        guard let savedName = TodoTask.savedName(from: name) else { return }
        if let editedTask = composer.editedTask {
            write {
                try await self.renameTask(id: editedTask.id, name: name)
                postAnnouncement(.taskRenamed(name: name))
            }
            // Saved under the typed name, so dismissing now drops nothing.
            composer.editedTask?.name = savedName
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
            startGracePeriod(of: task.id)
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

    // MARK: - Choosing a Day
    /// Gives `target` `day`, chosen in the floating Day `calendar`, unless the calendar is closed or closing, or it or
    /// the move rule refuses `day`. Returns whether the calendar shows `day` chosen: a refused Move shows nothing.
    func choose(_ day: Date, in calendar: FloatingDayCalendarState?, for target: DayChoiceTarget) -> Bool {
        guard let calendar, !calendar.isClosing, calendar.canChoose(day) else { return false }
        return choose(day, for: target)
    }

    /// Gives `target` `day` unless the move rule refuses it: the composer's Day steps to it, or the Task moves to the
    /// end of it. Nothing changes when `target` has `day` already. VoiceOver says a Task's new Day once its Move is
    /// saved. Returns whether `target` has `day` now.
    @discardableResult
    func choose(_ day: Date, for target: DayChoiceTarget) -> Bool {
        switch target {
        case .composer:
            return day == composer.day || changeComposerDay(to: day, onSaved: dayAnnouncement(day))
        case let .task(id):
            guard let task = scheduleTasks.task(withID: id) else { return false }
            return day == task.day || moveToEnd(task, of: day, onSaved: dayAnnouncement(day))
        }
    }

    /// Lists the Task with `id` by the usual rules again, once the composer, the Day picker or its row's calendar no
    /// longer has it.
    func stopListing(_ id: UUID) {
        restartGracePeriod(of: id)
        scheduleTasks.relist()
    }

    // MARK: - Helpers
    /// Sets the composer's Day to `day`, which can be planned for; an edited Task moves to the end of it at once, and
    /// `onSaved` runs once that's saved. Returns whether the Day changed: never on the composer's own Day.
    @discardableResult
    private func changeComposerDay(to day: Date, onSaved: @escaping @MainActor () -> Void = {}) -> Bool {
        guard day != composer.day else { return false }
        if let task = composer.editedTask {
            let moved = moveToEnd(task, of: day, onSaved: onSaved) {
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

    /// Moves `task` to `destination` and runs `onSaved` once the store has it, or lists it where it was when the
    /// move rule refuses that.
    private func move(_ task: TodoTask, to destination: MoveDestination, onSaved: @escaping @MainActor () -> Void) {
        // Moved at once, so the row stays where it was dropped while the write is in flight.
        guard scheduleTasks.move(task, to: destination) else { return }
        saveMove(task, to: destination, onSaved: onSaved)
    }

    /// Moves `task` to the end of `day` unless the move rule refuses it, and runs `onSaved` once the store has it, or
    /// `onFailure` once the Task is back where the store holds it. Returns whether it moved.
    private func moveToEnd(
        _ task: TodoTask,
        of day: Date,
        onSaved: @escaping @MainActor () -> Void,
        onFailure: @escaping @MainActor () -> Void = {}
    ) -> Bool {
        guard let destination = scheduleTasks.moveToEnd(task, of: day) else { return false }
        saveMove(task, to: destination, onSaved: onSaved, onFailure: onFailure)
        return true
    }

    /// Saves the Move of `task` to `destination`, already listed, and runs `onSaved` once the store has it, or
    /// `onFailure` once the Task is back where the store holds it.
    private func saveMove(
        _ task: TodoTask,
        to destination: MoveDestination,
        onSaved: @escaping @MainActor () -> Void,
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        write {
            try await self.repository.move(id: task.id, to: destination)
            onSaved()
        } onFailure: {
            // Nothing was saved, so the store's last Tasks put the Task back.
            self.scheduleTasks.dropUnsavedMoves()
            onFailure()
        }
    }

    /// Gives the Task with `id`, listed while the composer, the Day picker or its row's calendar had it, its grace
    /// period afresh when it's Complete and Complete Tasks are hidden, so it's seen before it leaves.
    private func restartGracePeriod(of id: UUID) {
        if !showsComplete, scheduleTasks.task(withID: id)?.isComplete == true {
            startGracePeriod(of: id)
        }
    }

    private func startGracePeriod(of id: UUID) {
        keptTasks.keep(id, for: UserDefaults.standard.keptDuration)
    }

    /// Has VoiceOver say `day`, named as it is now, when called: once a move to it is saved.
    private func dayAnnouncement(_ day: Date) -> @MainActor () -> Void {
        let dayName = day.relativeNameOrShortDate(today: today)
        return { postAnnouncement(dayName) }
    }

    /// What the Schedule lists its Tasks by now.
    private var listing: ScheduleListing {
        // The edited Task, and the one the Day picker or a row's calendar moves, stay listed until what has them
        // closes, even past their grace period, so they're seen as they move.
        let keptTaskIDs = keptTasks.ids.union(
            [composer.editedTask?.id, dayPicker?.target.taskID, taskDayCalendar?.taskID].compactMap { $0 }
        )
        return ScheduleListing(today: today, showsComplete: showsComplete, keptTaskIDs: keptTaskIDs)
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
