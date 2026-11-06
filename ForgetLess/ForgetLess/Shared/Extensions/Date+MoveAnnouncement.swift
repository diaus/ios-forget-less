import Foundation
import Utils

extension Date {
    /// Has VoiceOver say this Day, named as it is on `today`, when called: once a Move to it is saved.
    func moveAnnouncement(today: Date) -> @MainActor () -> Void {
        let dayName = relativeNameOrShortDate(today: today)
        return { postAnnouncement(dayName) }
    }

    /// Has VoiceOver say how many Tasks moved to this Day, named as it is on `today`, when called: once a Move of
    /// `taskCount` Tasks to it is saved.
    func moveAnnouncement(taskCount: Int, today: Date) -> @MainActor () -> Void {
        let message = LocalizedStringResource.scheduleOverdueMoved(
            count: taskCount, day: relativeNameOrShortDate(today: today)
        )
        return { postAnnouncement(message) }
    }
}
