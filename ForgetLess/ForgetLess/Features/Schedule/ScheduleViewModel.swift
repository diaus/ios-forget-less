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

    @ObservationIgnored @Injected(\.todoTaskRepository) private var repository
    @ObservationIgnored @Injected(\.addTask) private var addTask
    @ObservationIgnored @Injected(\.renameTask) private var renameTask

    init() {
        let today = Date.today
        self.today = today
        self.schedule = Schedule(tasks: [], today: today)
        self.composer = ComposerState(day: today)
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
                schedule = Schedule(tasks: tasks, today: today)
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
        write { try await self.repository.setComplete(id: task.id, isComplete: !task.isComplete, today: self.today) }
    }

    // MARK: - Deletion
    func delete(_ task: TodoTask) {
        write { try await self.repository.delete(id: task.id) }
    }

    // MARK: - Helpers
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
