import Domain
import Foundation
import Testing

/// Pins the weekday weeks start on for a test, or for every test in a suite, so it doesn't depend on the machine's
/// region. A test that pins its own with `Date.withFirstWeekday` overrides it.
struct FirstWeekdayTrait: TestTrait, SuiteTrait, TestScoping {
    /// Numbered as `Calendar` numbers weekdays (1 is Sunday).
    let firstWeekday: Int

    var isRecursive: Bool { true }

    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        try await Date.withFirstWeekday(firstWeekday, operation: function)
    }
}

extension Trait where Self == FirstWeekdayTrait {
    /// Weeks start on `firstWeekday`, numbered as `Calendar` numbers weekdays (1 is Sunday).
    static func firstWeekday(_ firstWeekday: Int) -> Self {
        Self(firstWeekday: firstWeekday)
    }
}
