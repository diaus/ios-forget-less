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
    var errorMessage: String?
    /// Whether the Schedule lists Complete Tasks. Kept across launches.
    var showsComplete: Bool {
        didSet {
            UserDefaults.standard.set(showsComplete, forKey: Self.showsCompleteKey)
            releaseKeptTasks()
            rebuildSchedule()
        }
    }
    /// Whether Tasks can be moved. Kept across launches.
    var movesTasks: Bool {
        didSet {
            UserDefaults.standard.set(movesTasks, forKey: Self.movesTasksKey)
        }
    }
    /// The Tasks the Schedule lists, with any move not yet confirmed by the store already made.
    private var tasks: [TodoTask] = []
    /// The Tasks last observed in the store.
    private var observedTasks: [TodoTask] = []
    /// Tasks completed while Complete Tasks are hidden that the Schedule still lists, so a mis-tap can be undone.
    private(set) var keptTaskIDs: Set<UUID> = []
    @ObservationIgnored private var keptTaskTimers: [UUID: Task<Void, Never>] = [:]

    private static let showsCompleteKey = "showsCompleteTasks"
    private static let movesTasksKey = "movesTasks"
    /// How long a Task completed while Complete Tasks are hidden stays listed, so a mis-tap can be undone.
    private static let keptDuration = Duration.seconds(2)

    @ObservationIgnored @Injected(\.todoTaskRepository) private var repository
    @ObservationIgnored @Injected(\.addTask) private var addTask
    @ObservationIgnored @Injected(\.renameTask) private var renameTask

    init() {
        let today = Date.today
        self.today = today
        self.schedule = Schedule(tasks: [], today: today)
        self.composer = ComposerState(day: today)
        self.showsComplete = UserDefaults.standard.object(forKey: Self.showsCompleteKey) as? Bool ?? true
        self.movesTasks = UserDefaults.standard.object(forKey: Self.movesTasksKey) as? Bool ?? true
    }

    // MARK: - Loading
    /// Brings Today up to date.
    func refresh() {
        today = .today
    }

    /// Keeps the Schedule up to date with the stored Tasks for the current Today, until the calling task is cancelled.
    func observeSchedule() async {
        do {
            for await tasks in try await repository.scheduleTasks(today: today) {
                observedTasks = tasks
                self.tasks = tasks
                rebuildSchedule()
            }
        } catch {
            errorMessage = error.userMessage
        }
    }

    // MARK: - Composer
    func showComposer(on day: Date) {
        composer.day = day
        composer.isVisible = true
    }

    /// Shows the composer filled in with `task`, to rename it.
    func showComposer(editing task: TodoTask) {
        composer.editedTask = task
        composer.taskName = task.name
        composer.day = task.day
        composer.isVisible = true
    }

    /// Hides the composer and drops what's typed, so the next add starts blank.
    func dismissComposer() {
        composer.isVisible = false
        composer.editedTask = nil
        composer.taskName = ""
    }

    /// Saves the typed name: adds a Task to the composer's Day, or renames the Task being edited. Returns `nil` and
    /// saves nothing when the typed name can't be saved.
    func submitComposer() -> ComposerSubmission? {
        guard composer.canSubmit else { return nil }
        let name = composer.taskName
        if let editedTask = composer.editedTask {
            write {
                try await self.renameTask(id: editedTask.id, name: name)
                postAnnouncement(.taskRenamed(name: name))
            }
            // Saved under the typed name, so dismissing now drops nothing.
            composer.editedTask?.name = name.trimmed
            return .renamed
        }
        let day = composer.day
        // Cleared at once, so a second submit before the write lands adds nothing.
        composer.taskName = ""
        write {
            try await self.addTask(name: name, day: day)
            postAnnouncement(.taskAdded(name: name))
        } onFailure: {
            // Give the name back unless the user has started typing another.
            if self.composer.taskName.isEmpty {
                self.composer.taskName = name
            }
        }
        return .added
    }

    // MARK: - Completion
    func toggleComplete(_ task: TodoTask) {
        let isComplete = !task.isComplete
        if isComplete && !showsComplete {
            keep(task.id)
        } else {
            // Stays kept, so no rebuild drops it before the Tasks observed hold it Incomplete.
            keptTaskTimers.removeValue(forKey: task.id)?.cancel()
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
        let day = destination.day.relativeNameOrShortDate(today: today)
        move(task, to: destination) {
            postAnnouncement(day)
        }
    }

    // MARK: - Deletion
    func delete(_ task: TodoTask) {
        write { try await self.repository.delete(id: task.id) }
    }

    // MARK: - Helpers
    /// Moves `task` to `destination` and runs `onSaved` once the store has it, or lists it where it was when the
    /// move rule refuses that.
    private func move(_ task: TodoTask, to destination: MoveDestination, onSaved: @escaping @MainActor () -> Void) {
        guard schedule.canMove(task, to: destination) else {
            // Rebuilt all the same, so a list that already moved the row puts it back.
            rebuildSchedule()
            return
        }
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
        }
    }

    /// Gives the Task with `id` its grace period while Complete Tasks are hidden.
    private func keep(_ id: UUID) {
        keptTaskIDs.insert(id)
        keptTaskTimers[id]?.cancel()
        keptTaskTimers[id] = Task {
            try? await Task.sleep(for: Self.keptDuration)
            guard !Task.isCancelled else { return }
            keptTaskTimers[id] = nil
            keptTaskIDs.remove(id)
            rebuildSchedule()
        }
    }

    private func releaseKeptTasks() {
        keptTaskTimers.values.forEach { $0.cancel() }
        keptTaskTimers = [:]
        keptTaskIDs = []
    }

    private func rebuildSchedule() {
        schedule = Schedule(tasks: tasks, today: today, showsComplete: showsComplete, keptTaskIDs: keptTaskIDs)
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

    /// What submitting the composer did.
    enum ComposerSubmission {
        /// A Task was added, and the composer stays up for the next one.
        case added
        /// The edited Task was renamed; nothing is left to save.
        case renamed
    }
}
