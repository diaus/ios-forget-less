import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Drives the Schedule screen.
@MainActor @Observable
final class ScheduleViewModel {
    private(set) var today: Date
    /// The floating Day calendar opened from a Task's row; `nil` while it's closed.
    var taskDayCalendar: TaskDayCalendar?
    /// The Day picker's choice; `nil` once it has closed. Kept until then, so the sheet keeps its content as it goes.
    var dayPicker: DayPickerState?
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
    let scheduleTasks: ScheduleTasks
    let keptTasks = KeptTasks()
    let writes: ScheduleWrites
    let composerSession: ComposerSession
    private let taskMoves: TaskMoves

    @ObservationIgnored @Injected(\.todoTaskRepository) private var repository

    init() {
        let today = Date.today
        let scheduleTasks = ScheduleTasks(today: today)
        let writes = ScheduleWrites()
        let taskMoves = TaskMoves(scheduleTasks: scheduleTasks, writes: writes)
        self.today = today
        self.showsComplete = UserDefaults.standard.showsComplete
        self.movesTasks = UserDefaults.standard.movesTasks
        self.scheduleTasks = scheduleTasks
        self.writes = writes
        self.taskMoves = taskMoves
        self.composerSession = ComposerSession(
            today: today, scheduleTasks: scheduleTasks, taskMoves: taskMoves, writes: writes
        )
        // Unowned: the view model holds the Tasks, so it outlives them. Only now, with `self` whole, can the listing
        // read the composer session, which itself holds the Tasks.
        scheduleTasks.listing = { [unowned self] in listing }
        keptTasks.onRelease = { [weak self] in self?.scheduleTasks.relist() }
        composerSession.onStopEditing = { [weak self] in self?.stopListing($0) }
    }

    // MARK: - Loading
    /// Brings Today up to date.
    func refresh() {
        today = .today
        dayPicker?.update(today: today)
        composerSession.update(today: today)
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
            writes.errorMessage = error.userMessage
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
        writes.run { try await self.repository.setComplete(id: task.id, isComplete: isComplete, today: self.today) }
    }

    // MARK: - Moving
    /// Moves `task` to `destination`, or lists it where it was when the move rule refuses that.
    func move(_ task: TodoTask, to destination: MoveDestination) {
        taskMoves.move(task, to: destination)
    }

    /// Moves `task` to `destination`, and has VoiceOver say its new Day once the move is saved.
    func moveAnnouncingDay(_ task: TodoTask, to destination: MoveDestination) {
        taskMoves.move(task, to: destination, onSaved: destination.day.moveAnnouncement(today: today))
    }

    // MARK: - Deletion
    func delete(_ task: TodoTask) {
        writes.run { try await self.repository.delete(id: task.id) }
    }

    // MARK: - Choosing a Day
    /// Gives `target` `day` unless the move rule refuses it: the composer's Day steps to it, or the Task moves to the
    /// end of it. Nothing changes when `target` has `day` already. VoiceOver says a Task's new Day once its Move is
    /// saved. Returns whether `target` has `day` now.
    @discardableResult
    func choose(_ day: Date, for target: DayChoiceTarget) -> Bool {
        switch target {
        case .composer:
            return composerSession.choose(day)
        case let .task(id):
            guard let task = scheduleTasks.task(withID: id) else { return false }
            return day == task.day || taskMoves.moveToEnd(task, of: day, onSaved: day.moveAnnouncement(today: today))
        }
    }

    /// Lists the Task with `id` by the usual rules again, once the composer, the Day picker or its row's calendar no
    /// longer has it.
    func stopListing(_ id: UUID) {
        restartGracePeriod(of: id)
        scheduleTasks.relist()
    }

    // MARK: - Helpers
    /// Gives the Task with `id`, listed while the composer, the Day picker or its row's calendar had it, its grace
    /// period afresh when it's Complete and Complete Tasks are hidden, so it's seen before it leaves.
    private func restartGracePeriod(of id: UUID) {
        if !showsComplete, scheduleTasks.task(withID: id)?.isComplete == true {
            startGracePeriod(of: id)
        }
    }

    private func startGracePeriod(of id: UUID) {
        keptTasks.keep(id, for: .seconds(UserDefaults.standard.keptDuration))
    }

    /// What the Schedule lists its Tasks by now.
    private var listing: ScheduleListing {
        // The edited Task, and the one the Day picker or a row's calendar moves, stay listed until what has them
        // closes, even past their grace period, so they're seen as they move.
        let heldTaskIDs = [composerSession.composer.editedTask?.id, dayPicker?.target.taskID, taskDayCalendar?.taskID]
        let keptTaskIDs = keptTasks.ids.union(heldTaskIDs.compactMap { $0 })
        return ScheduleListing(today: today, showsComplete: showsComplete, keptTaskIDs: keptTaskIDs)
    }
}
