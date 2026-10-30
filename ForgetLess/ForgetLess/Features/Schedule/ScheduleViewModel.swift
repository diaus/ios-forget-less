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
    /// Serialises adds, so two at once can't take the same place in a Day.
    @ObservationIgnored private var latestAdd: Task<Void, Never>?

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

    func dismissComposer() {
        composer.isVisible = false
    }

    /// Adds the typed Task to the composer's Day.
    func submitComposer() {
        guard composer.canSubmit else { return }
        let taskName = composer.taskName
        let day = composer.day
        // Cleared at once, so a second submit before the write lands adds nothing.
        composer.taskName = ""
        let previousAdd = latestAdd
        latestAdd = Task {
            await previousAdd?.value
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
    private func reloadSchedule() async {
        do {
            let tasks = try await repository.tasks(onOrAfter: today)
            schedule = Schedule(tasks: tasks, today: today)
        } catch {
            errorMessage = error.userMessage
        }
    }
}
