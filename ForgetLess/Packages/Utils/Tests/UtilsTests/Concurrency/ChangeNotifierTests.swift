import Testing
import Utils

struct ChangeNotifierTests {
    @Test func everySubscriberReceivesEachNotification() async {
        let notifier = ChangeNotifier()
        var first = notifier.changes.makeAsyncIterator()
        var second = notifier.changes.makeAsyncIterator()

        notifier.notify()

        #expect(await first.next() != nil)
        #expect(await second.next() != nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func aBurstOfNotificationsReachesASubscriberAsOne() async {
        var notifier: ChangeNotifier? = ChangeNotifier()
        var iterator = notifier!.changes.makeAsyncIterator()

        notifier!.notify()
        notifier!.notify()
        notifier = nil

        #expect(await iterator.next() != nil)
        #expect(await iterator.next() == nil)
    }
}
