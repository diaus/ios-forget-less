import Accessibility
import Foundation

/// Has VoiceOver speak `message` at once.
public func postAnnouncement(_ message: LocalizedStringResource) {
    AccessibilityNotification.Announcement(String(localized: message).highPriorityAnnouncement).post()
}
