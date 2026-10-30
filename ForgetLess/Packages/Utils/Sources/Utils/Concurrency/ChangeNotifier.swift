/// Broadcasts "something changed" to every subscriber, for consumers that reload everything on a change
/// and so need only the newest signal: a burst of notifications reaches a busy subscriber as one.
public final class ChangeNotifier: Sendable {
    private let subject = AsyncPassthroughSubject<Void>()

    public init() {}

    /// A new stream that yields after each notification until the consumer stops iterating.
    /// It is subscribed on access, so read it before work whose changes it must not miss.
    public var changes: AsyncStream<Void> {
        subject.subscribe(bufferingPolicy: .bufferingNewest(1))
    }

    public func notify() {
        subject.send(())
    }
}
