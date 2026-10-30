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

    init(
        repository: any TodoTaskRepository = Container.shared.todoTaskRepository(),
        addTask: AddTask = Container.shared.addTask()
    ) {
        let today = Date.today
        self.today = today
        self.schedule = Schedule(tasks: [], today: today)
        self.composer = ComposerState(day: today)
        self.repository = repository
        self.addTask = addTask
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

    /// Adds the typed Task to the composer's Day and keeps the composer up, or renames the Task being edited and
    /// hides the composer. Does nothing and returns `nil` when the typed name can't be saved.
    func submitComposer() -> ComposerSubmission? {
        guard composer.canSubmit else { return nil }
        if let editedTask = composer.editedTask {
            // The name rule: `canSubmit` has refused a blank name, and the name is saved trimmed.
            rename(editedTask, to: composer.taskName.trimmed)
            // Hidden here rather than by the user's dismissal, so a saved edit never counts as unsaved.
            dismissComposer()
            return .renamed
        }
        let taskName = composer.taskName
        let day = composer.day
        // Cleared at once, so a second submit before the write lands adds nothing.
        composer.taskName = ""
        Task {
            do {
                try await addTask(name: taskName, day: day)
                postAnnouncement(.taskAdded(name: taskName))
                await reloadSchedule()
            } catch {
                // Give the name back unless the user has started typing another.
                if composer.taskName.isEmpty {
                    composer.taskName = taskName
                }
                errorMessage = error.userMessage
            }
        }
        return .added
    }

    // MARK: - Completion
    func toggleComplete(_ task: TodoTask) {
        Task {
            do {
                try await repository.setComplete(id: task.id, isComplete: !task.isComplete)
                await reloadSchedule()
            } catch {
                errorMessage = error.userMessage
            }
        }
    }

    // MARK: - Helpers
    private func rename(_ task: TodoTask, to name: String) {
        Task {
            do {
                try await repository.rename(id: task.id, name: name)
                await reloadSchedule()
            } catch {
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
        /// The edited Task was renamed, and the composer is hidden.
        case renamed
    }
}
