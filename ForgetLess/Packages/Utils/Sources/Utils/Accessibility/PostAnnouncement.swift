import Accessibility
import Foundation

/// Has VoiceOver speak `message` at once.
public func postAnnouncement(_ message: LocalizedStringResource) {
    postAnnouncement(String(localized: message))
}

/// Has VoiceOver speak `message`, already localized, at once.
public func postAnnouncement(_ message: String) {
    AccessibilityNotification.Announcement(message.highPriorityAnnouncement).post()
}
