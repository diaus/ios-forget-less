import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Owns Today, its Tasks, the composer state and every write on the Schedule screen.
@MainActor @Observable
final class ScheduleViewModel {
    private(set) var today: Date
    /// Today's Tasks in the order they were added.
    private(set) var todayTasks: [TodoTask] = []
    var composer: ComposerState
    var errorMessage: String?

    @ObservationIgnored private let repository: any TodoTaskRepository
    @ObservationIgnored private let addTask: AddTask
    /// The latest add, which the next one waits for: each reads its Day's Tasks before creating, so two at once
    /// could take the same place.
    @ObservationIgnored private var latestAdd: Task<Void, Never>?

    init(
        repository: any TodoTaskRepository = Container.shared.todoTaskRepository(),
        addTask: AddTask = Container.shared.addTask()
    ) {
        let today = Calendar.current.startOfDay(for: .now)
        self.today = today
        self.composer = ComposerState(day: today)
        self.repository = repository
        self.addTask = addTask
    }

    func load() async {
        today = Calendar.current.startOfDay(for: .now)
        await reloadTodayTasks()
    }

    func showComposer() {
        composer.day = today
        composer.isVisible = true
    }

    func dismissComposer() {
        composer.isVisible = false
    }

    /// Adds the typed Task to the composer's Day and clears the name, keeping the composer up on the same Day.
    /// The name clears at once, so a second ▶ or Return before the write lands adds nothing.
    func submitComposer() {
        guard composer.canSubmit else { return }
        let taskName = composer.taskName
        let day = composer.day
        composer.taskName = ""
        let previousAdd = latestAdd
        latestAdd = Task {
            await previousAdd?.value
            do {
                try await addTask(name: taskName, day: day)
                await reloadTodayTasks()
            } catch {
                // Give the name back unless the user has started typing another.
                if composer.taskName.isEmpty {
                    composer.taskName = taskName
                }
                errorMessage = error.userMessage
            }
        }
    }

    private func reloadTodayTasks() async {
        do {
            todayTasks = try await repository.tasks(on: today).sorted { $0.sortIndex < $1.sortIndex }
        } catch {
            errorMessage = error.userMessage
        }
    }
}
