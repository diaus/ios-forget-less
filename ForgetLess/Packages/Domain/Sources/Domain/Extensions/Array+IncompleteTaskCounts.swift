import Foundation

public extension Array where Element == TodoTask {
    /// How many Incomplete Tasks each Day holds. A Day with none has no entry.
    var incompleteTaskCountsByDay: [Date: Int] {
        filter { !$0.isComplete }.reduce(into: [:]) { counts, task in
            counts[task.day, default: 0] += 1
        }
    }
}
