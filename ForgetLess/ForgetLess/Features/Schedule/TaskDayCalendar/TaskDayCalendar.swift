import Foundation

/// The floating Day calendar opened from a Task's row, to Move that Task.
struct TaskDayCalendar {
    let taskID: UUID
    /// Where the Task's row was tapped, which the calendar grows from.
    let origin: TaskDayCalendarOrigin
    var calendar: FloatingDayCalendarState
}
