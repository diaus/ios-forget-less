import Foundation
import Utils

extension Date {
    /// Has VoiceOver say this Day, named as it is on `today`, when called: once a Move to it is saved.
    func moveAnnouncement(today: Date) -> @MainActor () -> Void {
        let dayName = relativeNameOrShortDate(today: today)
        return { postAnnouncement(dayName) }
    }
}
