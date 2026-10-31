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
            guard let completeDay = task.completeDay else { continue }
            // `create` picks its own ID, so the stored Task is found by its name.
            if let stored = try await repository.tasks(on: task.day).first(where: { $0.name == task.name }) {
                try await repository.setComplete(id: stored.id, isComplete: true, today: completeDay)
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
