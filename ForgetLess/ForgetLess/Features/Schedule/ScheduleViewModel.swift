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

    @ObservationIgnored private let repository: any TodoTaskRepository
    @ObservationIgnored private let addTask: AddTask
    @ObservationIgnored private let renameTask: RenameTask

    init(
        repository: any TodoTaskRepository = Container.shared.todoTaskRepository(),
        addTask: AddTask = Container.shared.addTask(),
        renameTask: RenameTask = Container.shared.renameTask()
    ) {
        let today = Date.today
        self.today = today
        self.schedule = Schedule(tasks: [], today: today)
        self.composer = ComposerState(day: today)
        self.repository = repository
        self.addTask = addTask
        self.renameTask = renameTask
    }

    // MARK: - Loading
    func load() async {
        today = .today
        await reloadSchedule()
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

    func dismissComposer() {
        composer.isVisible = false
        // An edit left unsaved is dropped, so the next add starts blank.
        if composer.editedTask != nil {
            composer.editedTask = nil
            composer.taskName = ""
        }
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
        write { try await self.repository.setComplete(id: task.id, isComplete: !task.isComplete) }
    }

    // MARK: - Helpers
    /// Runs `operation`, then reloads the Schedule; on failure, runs `onFailure` and shows the error.
    private func write(
        _ operation: @escaping @MainActor () async throws -> Void,
        onFailure: @escaping @MainActor () -> Void = {}
    ) {
        Task {
            do {
                try await operation()
                await reloadSchedule()
            } catch {
                onFailure()
                errorMessage = error.userMessage
            }
        }
    }

    private func reloadSchedule() async {
        do {
            let tasks = try await repository.tasks(onOrAfter: today)
            schedule = Schedule(tasks: tasks, today: today)
        } catch {
            errorMessage = error.userMessage
        }
    }

    /// What submitting the composer did.
    enum ComposerSubmission {
        /// A Task was added, and the composer stays up for the next one.
        case added
        /// The edited Task was renamed; the caller closes the composer.
        case renamed
    }
}
