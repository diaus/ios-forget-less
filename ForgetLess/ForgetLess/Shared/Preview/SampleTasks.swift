import Data
import Domain
import FactoryKit
import SwiftUI

/// Fills the preview's store with `TodoTask.previewAll`.
struct SampleTasks: PreviewModifier {
    static func makeSharedContext() async throws {
        let repository = Container.shared.todoTaskRepository()
        for task in TodoTask.previewAll {
            try await repository.create(name: task.name, day: task.day)
            guard let completeTime = task.completeTime else { continue }
            // `create` picks its own ID, so the stored Task, Incomplete until now, is found by its name.
            let createdOnDay = try await repository.upcomingTasks(
                from: task.day, through: task.day, completedWithin: 0, before: .now
            )
            if let stored = createdOnDay.first(where: { $0.name == task.name }) {
                try await repository.setComplete(id: stored.id, isComplete: true, now: completeTime)
            }
        }
    }

    func body(content: Content, context: Void) -> some View {
        content
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    /// Previews the view over a store holding the sample Tasks.
    static var sampleTasks: Self { .modifier(SampleTasks()) }
}
