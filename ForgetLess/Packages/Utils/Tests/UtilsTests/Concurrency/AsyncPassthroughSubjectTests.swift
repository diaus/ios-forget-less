import Testing
import Utils

struct AsyncPassthroughSubjectTests {
    @Test func everySubscriberReceivesEachValue() async {
        let subject = AsyncPassthroughSubject<Int>()
        var first = subject.subscribe().makeAsyncIterator()
        var second = subject.subscribe().makeAsyncIterator()

        subject.send(1)
        subject.send(2)

        #expect(await first.next() == 1)
        #expect(await first.next() == 2)
        #expect(await second.next() == 1)
        #expect(await second.next() == 2)
    }

    @Test func finishEndsEverySubscriberAfterItsBufferedValues() async {
        let subject = AsyncPassthroughSubject<Int>()
        var iterator = subject.subscribe().makeAsyncIterator()

        subject.send(1)
        subject.finish()

        #expect(await iterator.next() == 1)
        #expect(await iterator.next() == nil)
    }

    @Test func aSubscriberBufferingTheNewestValueSkipsTheOlderOnes() async {
        let subject = AsyncPassthroughSubject<Int>()
        var newest = subject.subscribe(bufferingPolicy: .bufferingNewest(1)).makeAsyncIterator()
        var every = subject.subscribe().makeAsyncIterator()

        subject.send(1)
        subject.send(2)
        subject.finish()

        #expect(await newest.next() == 2)
        #expect(await newest.next() == nil)
        #expect(await every.next() == 1)
        #expect(await every.next() == 2)
    }

    @Test func subscribingAfterFinishGetsAnEndedStream() async {
        let subject = AsyncPassthroughSubject<Int>()
        subject.finish()

        var iterator = subject.subscribe().makeAsyncIterator()
        subject.send(1)

        #expect(await iterator.next() == nil)
    }

    @Test(.timeLimit(.minutes(1)))
    func releasingTheSubjectEndsItsSubscribers() async {
        var subject: AsyncPassthroughSubject<Int>? = AsyncPassthroughSubject()
        var iterator = subject!.subscribe().makeAsyncIterator()

        subject = nil

        #expect(await iterator.next() == nil)
    }
}
