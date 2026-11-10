import Foundation

public extension Array where Element == TodoTask {
    /// The moments, in order and each once, at which the Grace Period of these Tasks' Complete ones ends, when it lasts
    /// `gracePeriod`: those before `end` only (ADR 0005).
    func gracePeriodEnds(lasting gracePeriod: TimeInterval, before end: Date) -> [Date] {
        Set(compactMap { $0.completeTime?.addingTimeInterval(gracePeriod) }).filter { $0 < end }.sorted()
    }
}
