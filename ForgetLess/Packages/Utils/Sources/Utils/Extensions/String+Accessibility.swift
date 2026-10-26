import Accessibility

public extension String {
    /// The receiver as an `AttributedString` with `.high` speech-announcement priority, so its announcement
    /// interrupts other VoiceOver speech.
    var highPriorityAnnouncement: AttributedString {
        var announcement = AttributedString(self)
        announcement.accessibilitySpeechAnnouncementPriority = .high
        return announcement
    }
}
