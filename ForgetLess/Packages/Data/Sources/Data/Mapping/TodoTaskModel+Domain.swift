import Domain
import Foundation

extension TodoTaskModel {
    convenience init(_ task: TodoTask) {
        self.init(
            id: task.id,
            name: task.name,
            day: task.day,
            completeDay: task.completeDay,
            sortIndex: task.sortIndex
        )
    }

    func toDomain() -> TodoTask {
        TodoTask(
            id: id,
            name: name,
            day: day,
            completeDay: completeDay,
            sortIndex: sortIndex
        )
    }
}
