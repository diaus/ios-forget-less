import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct KeptTasksTests {
    // MARK: - Tests
    @Test(.timeLimit(.minutes(1)))
    func aKeptTaskIsReleasedOnceItsGracePeriodEnds() async {
        let keptTasks = KeptTasks()
        let releases = releaseStream(of: keptTasks)
        let id = UUID()

        keptTasks.keep(id, for: .seconds(0.01))
        #expect(keptTasks.ids == [id])
        for await _ in releases { break }

        #expect(keptTasks.ids.isEmpty)
    }

    @Test func aTaskKeptForNoTimeIsNoLongerKeptEvenIfItWasBefore() {
        let keptTasks = KeptTasks()
        let id = UUID()
        keptTasks.keep(id, for: .seconds(60))

        keptTasks.keep(id, for: .zero)

        #expect(keptTasks.ids.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func aTaskWhoseGracePeriodIsStoppedStaysKeptPastIt() async {
        let keptTasks = KeptTasks()
        let releases = releaseStream(of: keptTasks)
        let stopped = UUID()
        keptTasks.keep(stopped, for: .seconds(0.01))
        keptTasks.stopGracePeriod(of: stopped)

        // Released well after the stopped Task's grace period would have ended.
        keptTasks.keep(UUID(), for: .seconds(0.3))
        for await _ in releases { break }

        #expect(keptTasks.ids == [stopped])
    }

    @Test func releasingAllKeepsNoTask() {
        let keptTasks = KeptTasks()
        keptTasks.keep(UUID(), for: .seconds(60))
        keptTasks.keep(UUID(), for: .seconds(60))

        keptTasks.releaseAll()

        #expect(keptTasks.ids.isEmpty)
    }

    // MARK: - Helpers
    private func releaseStream(of keptTasks: KeptTasks) -> AsyncStream<Void> {
        let (releases, continuation) = AsyncStream<Void>.makeStream()
        keptTasks.onRelease = { continuation.yield() }
        return releases
    }
}
