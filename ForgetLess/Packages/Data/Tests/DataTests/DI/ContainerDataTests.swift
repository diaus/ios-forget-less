import FactoryKit
import FactoryTesting
import Foundation
import Synchronization
import Testing
@testable import Data

struct ContainerDataTests {
    @Test(.container) func anAfterSaveHookRegisteredAfterTheRepositoryIsMadeStillRuns() async throws {
        let modelContainer = try ForgetLessModelContainer.makeInMemory()
        Container.shared.modelContainer.register { modelContainer }
        let repository = Container.shared.todoTaskRepository()
        let saves = Mutex(0)

        Container.shared.afterStoreSave.register { { saves.withLock { $0 += 1 } } }
        try await repository.create(name: "Buy milk", day: Date(timeIntervalSince1970: 1_792_886_400))

        #expect(saves.withLock { $0 } == 1)
    }
}
