import Domain
import Testing

struct TaskNameTests {
    @Test func trimsWhitespaceAndNewlinesAroundATaskName() throws {
        #expect(try validatedTaskName(" \n Buy milk\t \n") == "Buy milk")
    }

    @Test(arguments: ["", " \t\n "])
    func refusesATaskNameThatIsEmptyAfterTrimming(_ name: String) {
        #expect(throws: DomainError.emptyName) { try validatedTaskName(name) }
    }
}
