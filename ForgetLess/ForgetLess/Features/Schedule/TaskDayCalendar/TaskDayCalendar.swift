import Foundation

/// The floating Day calendar opened from a Task's row, to Move that Task.
struct TaskDayCalendar {
    let taskID: UUID
    var calendar: FloatingDayCalendarState
}
