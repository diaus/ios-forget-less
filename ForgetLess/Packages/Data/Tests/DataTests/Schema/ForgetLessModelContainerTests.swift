import SwiftData
import Testing
@testable import Data

struct ForgetLessModelContainerTests {
    @Test func anInMemoryContainerOpensWithTheSchemaAndSaves() throws {
        let container = try ForgetLessModelContainer.makeInMemory()

        try ModelContext(container).save()
        #expect(container.configurations.allSatisfy { $0.isStoredInMemoryOnly })
    }
}
