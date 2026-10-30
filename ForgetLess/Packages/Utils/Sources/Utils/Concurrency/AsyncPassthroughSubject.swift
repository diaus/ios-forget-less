import Synchronization

/// Broadcasts each sent value to every current subscriber, like Combine's `PassthroughSubject`.
/// Each subscriber gets its own `AsyncStream`, so one slow subscriber never holds up the others.
public final class AsyncPassthroughSubject<Element: Sendable>: Sendable {
    private struct Subscriber {
        var id: Int
        var continuation: AsyncStream<Element>.Continuation
    }

    private struct State {
        var nextID = 0
        var subscribers: [Subscriber] = []
        var isFinished = false
    }

    private let state = Mutex(State())

    public init() {}

    /// Nothing can send once the subject is gone, so its subscribers end instead of waiting forever.
    deinit {
        finish()
    }

    /// A new stream that receives every value sent from now on, until the consumer stops iterating
    /// or the subject finishes. After `finish()`, the stream has already ended.
    /// - Parameter bufferingPolicy: What the stream keeps while its consumer is busy;
    ///   `.bufferingNewest(1)` suits a consumer that only needs to know something changed.
    public func subscribe(
        bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<Element> {
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: bufferingPolicy)
        let id: Int? = state.withLock { state in
            guard !state.isFinished else { return nil }
            let id = state.nextID
            state.nextID += 1
            state.subscribers.append(Subscriber(id: id, continuation: continuation))
            return id
        }
        guard let id else {
            continuation.finish()
            return stream
        }
        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { state in
                state.subscribers.removeAll { $0.id == id }
            }
        }
        return stream
    }

    public func send(_ value: Element) {
        let subscribers = state.withLock { $0.subscribers }
        for subscriber in subscribers {
            subscriber.continuation.yield(value)
        }
    }

    /// Ends every subscriber's stream once it has delivered the values already sent.
    public func finish() {
        let subscribers = state.withLock { state in
            state.isFinished = true
            defer { state.subscribers.removeAll() }
            return state.subscribers
        }
        // Outside the lock: finishing runs `onTermination`, which takes the lock again.
        for subscriber in subscribers {
            subscriber.continuation.finish()
        }
    }
}
