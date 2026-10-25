import Domain
import Foundation

extension TodoTaskModel {
    convenience init(_ task: TodoTask, calendar: Calendar) {
        self.init(
            id: task.id,
            name: task.name,
            day: DayEncoding.stored(task.day, calendar: calendar),
            isComplete: task.isComplete,
            sortIndex: task.sortIndex
        )
    }

    func toDomain(calendar: Calendar) -> TodoTask {
        TodoTask(
            id: id,
            name: name,
            day: DayEncoding.day(fromStored: day, calendar: calendar),
            isComplete: isComplete,
            sortIndex: sortIndex
        )
    }
}
