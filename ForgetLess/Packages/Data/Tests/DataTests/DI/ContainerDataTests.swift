import FactoryKit
import Foundation
import Synchronization
import Testing
@testable import Data

struct ContainerDataTests {
    @Test func anAfterSaveHookRegisteredAfterTheRepositoryIsMadeStillRuns() async throws {
        // A Singleton scope of the test's own, so the repository isn't shared with any other test.
        try await Scope.$singleton.withValue(Scope.Singleton()) {
            let container = Container()
            let modelContainer = try ForgetLessModelContainer.makeInMemory()
            container.modelContainer.register { modelContainer }
            let repository = container.todoTaskRepository()
            let saves = Mutex(0)

            container.afterStoreSave.register { { saves.withLock { $0 += 1 } } }
            try await repository.create(name: "Buy milk", day: Date(timeIntervalSince1970: 1_792_886_400))

            #expect(saves.withLock { $0 } == 1)
        }
    }
}
