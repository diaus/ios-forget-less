import Domain
import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct ComposerStateTests {
    /// Any Day: the rules read it only against Days stepped from it.
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
    func whileEditingOnlyATrimmedNameOtherThanTheSavedOneIsAChange(taskName: String, hasChanges: Bool) {
        var composer = ComposerState(day: day)
        composer.editedTask = TodoTask(id: UUID(), name: "Buy milk", day: day, completeDay: nil, sortIndex: 0)
        composer.taskName = taskName

        #expect(composer.hasChanges == hasChanges)
    }

    @Test func whileAddingADayIsRevealedOnlyOnceSteppedToAndAddedTo() {
        let friday = day.addingDays(4)
        var composer = ComposerState(day: day)
        composer.daysAddedTo.insert(day)
        #expect(!composer.revealsDayOnDismiss)

        composer.step(to: friday)
        #expect(!composer.revealsDayOnDismiss)

        composer.daysAddedTo.insert(friday)
        #expect(composer.revealsDayOnDismiss)

        composer.step(to: friday.addingDays(1))
        #expect(!composer.revealsDayOnDismiss)

        composer.step(to: friday)
        #expect(composer.revealsDayOnDismiss)
    }

    @Test func whileEditingADayIsRevealedOnceSteppedTo() {
        var composer = ComposerState(day: day)
        composer.editedTask = TodoTask(id: UUID(), name: "Buy milk", day: day, completeDay: nil, sortIndex: 0)
        #expect(!composer.revealsDayOnDismiss)

        composer.step(to: day.addingDays(1))
        #expect(composer.revealsDayOnDismiss)
    }

    @Test func aStepToADayFarAwayAsTheCalendarMakesIsRevealedAsAOneDayStepIs() {
        let farDay = day.addingDays(40)
        var composer = ComposerState(day: day)

        composer.step(to: farDay)
        composer.daysAddedTo.insert(farDay)

        #expect(composer.hasSteppedDay)
        #expect(composer.revealsDayOnDismiss)
    }

    @Test func startingAfreshForgetsStepsAndAdds() {
        var composer = ComposerState(day: day)
        composer.step(to: day.addingDays(1))
        composer.daysAddedTo.insert(day.addingDays(1))

        composer.start(on: day.addingDays(1))

        #expect(!composer.revealsDayOnDismiss)
    }
}
