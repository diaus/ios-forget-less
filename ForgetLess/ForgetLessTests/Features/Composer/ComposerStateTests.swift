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
        composer.editedTask = TodoTask(id: UUID(), name: "Buy milk", day: day, completeTime: nil, sortIndex: 0)
        composer.taskName = taskName

        #expect(composer.hasChanges == hasChanges)
    }

    @Test func whileAddingADayIsRevealedOnlyOnceSteppedToAndAddedTo() {
        let friday = day.addingDays(4)
        var composer = ComposerState(day: day)
        composer.clearForNextTask(afterAddingTo: day)
        #expect(!composer.revealsDayOnDismiss)

        composer.step(to: friday)
        #expect(!composer.revealsDayOnDismiss)

        composer.clearForNextTask(afterAddingTo: friday)
        #expect(composer.revealsDayOnDismiss)

        composer.step(to: friday.addingDays(1))
        #expect(!composer.revealsDayOnDismiss)

        composer.step(to: friday)
        #expect(composer.revealsDayOnDismiss)
    }

    @Test func whileEditingADayIsRevealedOnceSteppedTo() {
        var composer = ComposerState(day: day)
        composer.editedTask = TodoTask(id: UUID(), name: "Buy milk", day: day, completeTime: nil, sortIndex: 0)
        #expect(!composer.revealsDayOnDismiss)

        composer.step(to: day.addingDays(1))
        #expect(composer.revealsDayOnDismiss)
    }

    @Test func aStepToADayFarAwayAsTheFloatingDayPickerMakesIsRevealedAsAOneDayStepIs() {
        let farDay = day.addingDays(40)
        var composer = ComposerState(day: day)

        composer.step(to: farDay)
        composer.clearForNextTask(afterAddingTo: farDay)

        #expect(composer.hasSteppedDay)
        #expect(composer.revealsDayOnDismiss)
    }

    @Test func showingAfreshForgetsStepsAndAdds() {
        var composer = ComposerState(day: day)
        composer.step(to: day.addingDays(1))
        composer.clearForNextTask(afterAddingTo: day.addingDays(1))

        composer.show(on: day.addingDays(1))

        #expect(!composer.revealsDayOnDismiss)
    }

    @Test func addingATaskClearsTheNameAndKeepsTheKeyboardForTheNextOne() {
        var composer = ComposerState(day: day)
        composer.show(on: day)
        composer.taskName = "Buy milk"
        // As Return drops it.
        composer.isNameFocused = false

        composer.clearForNextTask(afterAddingTo: day)

        #expect(composer.taskName.isEmpty)
        #expect(composer.isNameFocused)
        #expect(composer.isVisible)
    }

    @Test func hidingDropsTheEditedTaskAndItsNameSoTheNextAddStartsBlank() {
        var composer = ComposerState(day: day)
        composer.show(editing: TodoTask(id: UUID(), name: "Buy milk", day: day, completeTime: nil, sortIndex: 0))
        composer.taskName = "Buy bread"

        composer.hide()
        composer.show(on: day)

        #expect(composer.editedTask == nil)
        #expect(composer.taskName.isEmpty)
        #expect(!composer.hasChanges)
    }

    @Test func askingToDiscardTakesOnlyTheKeyboardAndKeepingEditingGivesItBack() {
        var composer = ComposerState(day: day)
        composer.show(on: day)
        composer.taskName = "Buy milk"

        composer.askToDiscard()
        #expect(composer.isConfirmingDiscard)
        #expect(composer.isVisible)
        #expect(!composer.isNameFocused)

        composer.keepEditing()
        #expect(composer.isNameFocused)
        #expect(composer.taskName == "Buy milk")
    }

    @Test(arguments: [false, true])
    func returningFocusToTheDayChipBringsBackOnlyTheKeyboardItWasAskedTo(bringingBackKeyboard: Bool) {
        var composer = ComposerState(day: day)
        let focusCount = composer.dayChipAccessibilityFocusCount

        composer.returnFocusToDayChip(bringingBackKeyboard: bringingBackKeyboard)

        #expect(composer.isNameFocused == bringingBackKeyboard)
        #expect(composer.dayChipAccessibilityFocusCount != focusCount)
    }
}
