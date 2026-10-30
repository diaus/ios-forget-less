import Accessibility

public extension String {
    /// The receiver as an announcement that interrupts other VoiceOver speech.
    var highPriorityAnnouncement: AttributedString {
        var announcement = AttributedString(self)
        announcement.accessibilitySpeechAnnouncementPriority = .high
        return announcement
    }
}
