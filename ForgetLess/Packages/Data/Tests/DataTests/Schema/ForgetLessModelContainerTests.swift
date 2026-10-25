import SwiftData
import Testing
@testable import Data

struct ForgetLessModelContainerTests {
    @Test func anInMemoryContainerOpensWithTheSchemaAndSaves() throws {
        let container = try ForgetLessModelContainer.make(inMemory: true)

        try ModelContext(container).save()
        #expect(container.configurations.allSatisfy { $0.isStoredInMemoryOnly })
    }
}
