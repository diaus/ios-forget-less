import Accessibility
import Testing
import Utils

struct StringAccessibilityTests {
    @Test func aHighPriorityAnnouncementKeepsTheTextAndInterruptsOtherSpeech() {
        let announcement = "Added “Buy milk”".highPriorityAnnouncement

        #expect(String(announcement.characters) == "Added “Buy milk”")
        #expect(announcement.runs.count == 1)
        #expect(announcement.runs.first?.accessibilitySpeechAnnouncementPriority == .high)
    }
}
