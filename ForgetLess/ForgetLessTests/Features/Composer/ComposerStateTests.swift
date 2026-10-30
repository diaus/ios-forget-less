import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct ComposerStateTests {
    /// Any Day: the rule doesn't read it.
    private let day = Date(timeIntervalSince1970: 0)

    @Test(arguments: [
        ("", false),
        ("  \n", false),
        ("Buy milk", true),
    ])
    func whileAddingOnlyANonBlankNameIsAChange(taskName: String, hasChanges: Bool) {
        var composer = ComposerState(day: day)
        composer.taskName = taskName

        #expect(composer.hasChanges == hasChanges)
    }

    @Test(arguments: [
        ("Buy milk", false),
        (" Buy milk\n", false),
        ("  ", true),
        ("Buy bread", true),
    ])
    func whileRenamingOnlyATrimmedNameOtherThanTheSavedOneIsAChange(taskName: String, hasChanges: Bool) {
        var composer = ComposerState(day: day)
        composer.editedTask = TodoTask(id: UUID(), name: "Buy milk", day: day, completeDay: nil, sortIndex: 0)
        composer.taskName = taskName

        #expect(composer.hasChanges == hasChanges)
    }
}
