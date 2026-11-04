import Foundation
import Observation

/// Tasks completed while Complete Tasks are hidden that the Schedule still lists for their grace period, so a mis-tap
/// can be undone.
@MainActor @Observable
final class KeptTasks {
    private(set) var ids: Set<UUID> = []
    /// Runs once a Task's grace period has ended and it's no longer kept.
    @ObservationIgnored var onRelease: @MainActor () -> Void = {}
    @ObservationIgnored private var timers: [UUID: Task<Void, Never>] = [:]

    /// Keeps the Task with `id` for a grace period of `seconds`, in place of any it had. With no grace period, it's no
    /// longer kept, and `onRelease` doesn't run for it.
    func keep(_ id: UUID, for seconds: Double) {
        timers.removeValue(forKey: id)?.cancel()
        guard seconds > 0 else {
            ids.remove(id)
            return
        }
        ids.insert(id)
        timers[id] = Task {
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            timers[id] = nil
            ids.remove(id)
            onRelease()
        }
    }

    /// Keeps the Task with `id`, if it's kept, until it's kept again or every Task is released.
    func stopGracePeriod(of id: UUID) {
        timers.removeValue(forKey: id)?.cancel()
    }

    /// Keeps no Task any more, without running `onRelease`.
    func releaseAll() {
        timers.values.forEach { $0.cancel() }
        timers = [:]
        ids = []
    }
}
