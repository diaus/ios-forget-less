import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Drives the Schedule screen.
@MainActor @Observable
final class ScheduleViewModel {
    private(set) var today: Date
    /// The floating Day picker opened from a Task's row or the Overdue header; `nil` while it's closed.
    var floatingDayPicker: FloatingDayPickerPresentation?
    /// The sheet Day picker's choice; `nil` once it has closed. Kept until then, so the sheet keeps its content as it
    /// goes.
    var sheetDayPicker: SheetDayPickerState?
    /// Whether the Schedule lists Complete Tasks: always in History, else as the user chose.
    var showsComplete: Bool {
        get { showsCompleteChoice || showsHistory }
        set { showsCompleteChoice = newValue }
    }
    /// The user's Show Complete Tasks choice, kept as it was while History is on. Kept across launches.
    private var showsCompleteChoice: Bool {
        didSet {
            UserDefaults.standard.showsComplete = showsCompleteChoice
            keptTasks.releaseAll()
            scheduleTasks.relist()
        }
    }
    /// Whether the Schedule lists History. Off at every launch.
    var showsHistory = false {
        didSet {
            guard showsHistory != oldValue else { return }
            // A Day before Today the composer holds stays when History turns off: it was chosen on purpose.
            composerSession.showsHistory = showsHistory
            // Set here, and listed once the Tasks from it are observed, which restarts the observation.
            historyFirstDay = showsHistory ? today.addingDays(-Self.historyPageDayCount) : nil
            // Released without relisting: the next Tasks observed relist in the same update as the new listing.
            keptTasks.releaseAll()
        }
    }
    /// The first Day the Schedule is observed from in History, or `nil` outside History.
    private(set) var historyFirstDay: Date?
    /// The list's last jump on History turning on or off; `nil` before the first.
    private(set) var historyJump: HistoryJump?
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
        self.showsCompleteChoice = UserDefaults.standard.showsComplete
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
    /// How many Days further back History lists each time the list nears its top.
    private static let historyPageDayCount = 60

    /// Brings Today up to date.
    func refresh() {
        today = .today
        sheetDayPicker?.update(today: today)
        composerSession.update(today: today)
        floatingDayPicker?.picker.update(today: today)
    }

    /// Keeps the Schedule up to date with the stored Tasks for the current Today, and the History first Day, until the
    /// calling task is cancelled.
    func observeSchedule() async {
        let historyFirstDay = historyFirstDay
        do {
            for await tasks in try await repository.scheduleTasks(today: today, historyFirstDay: historyFirstDay) {
                let listedHistory = scheduleTasks.historyFirstDay != nil
                scheduleTasks.observe(tasks, historyFirstDay: historyFirstDay)
                // Once the Tasks for the new listing are in, so the list jumps within the Schedule it then shows.
                // Neither a page loaded further back nor a new Today jumps.
                if (historyFirstDay != nil) != listedHistory {
                    historyJump = HistoryJump(to: historyFirstDay != nil ? .yesterday : .top)
                }
                closeFloatingDayPickerWithNothingToMove()
                closeSheetDayPickerWithNothingToMove()
            }
        } catch {
            writes.errorMessage = error.userMessage
        }
    }

    /// Lists the Days further back in History, unless the Schedule lists outside History or a page further back is
    /// still loading.
    func loadEarlierHistory() {
        guard let historyFirstDay, historyFirstDay == scheduleTasks.historyFirstDay else { return }
        self.historyFirstDay = historyFirstDay.addingDays(-Self.historyPageDayCount)
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
    /// Gives `target` `day` unless the move rule refuses it: the composer's Day steps to it, a Task moves to the end of
    /// it, or the Tasks Overdue now move to the top of it. Nothing changes when `target` has `day` already. VoiceOver
    /// says the new Day once a Move is saved. Returns whether `target` has `day` now: `false` when nothing is Overdue.
    @discardableResult
    func choose(_ day: Date, for target: DayChoiceTarget) -> Bool {
        switch target {
        case .composer:
            return composerSession.choose(day)
        case let .task(id):
            guard let task = scheduleTasks.task(withID: id) else { return false }
            return day == task.day || taskMoves.moveToEnd(task, of: day, onSaved: day.moveAnnouncement(today: today))
        case .overdueTasks:
            let taskCount = scheduleTasks.schedule.overdueIncomplete.count
            return taskMoves.moveOverdueTasks(
                toStartOf: day, onSaved: day.moveAnnouncement(taskCount: taskCount, today: today)
            )
        }
    }

    /// Lists the Task with `id` by the usual rules again, once the composer, the sheet Day picker or its row's floating
    /// Day picker no longer has it.
    func stopListing(_ id: UUID) {
        restartGracePeriod(of: id)
        scheduleTasks.relist()
    }

    // MARK: - Helpers
    /// Gives the Task with `id`, listed while the composer, the sheet Day picker or its row's floating Day picker had
    /// it, its grace period afresh when it's Complete and Complete Tasks are hidden, so it's seen before it leaves.
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
        // The edited Task, and the one the sheet Day picker or a row's floating Day picker moves, stay listed until
        // what has them closes, even past their grace period, so they're seen as they move.
        let heldTaskIDs = [
            composerSession.composer.editedTask?.id, sheetDayPicker?.target.taskID, floatingDayPicker?.target.taskID,
        ]
        let keptTaskIDs = keptTasks.ids.union(heldTaskIDs.compactMap { $0 })
        return ScheduleListing(today: today, showsComplete: showsComplete, keptTaskIDs: keptTaskIDs)
    }
}
