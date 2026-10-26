import Accessibility
import Foundation

/// Has VoiceOver speak `message`, interrupting whatever it's saying, such as the element focus is on.
public func postAnnouncement(_ message: LocalizedStringResource) {
    AccessibilityNotification.Announcement(String(localized: message).highPriorityAnnouncement).post()
}
