import Domain
import Foundation

// One file per Day chooser. Each gives its Day through the view model's shared Day chooser.
extension ScheduleViewModel {
    // MARK: - Task Day Calendar
    /// Opens the floating Day calendar on `task`'s Day, by its row tapped as `origin` says, to Move it to another.
    func showTaskDayCalendar(for task: TodoTask, from origin: TaskDayCalendarOrigin) {
        let calendar = FloatingDayCalendarState(today: today, day: task.day)
        taskDayCalendar = TaskDayCalendar(taskID: task.id, origin: origin, calendar: calendar)
    }

    /// Moves the Task to the end of `day`, unless it's there already, the calendar is closing, or it or the move rule
    /// refuses `day`. VoiceOver says the new Day once the Move is saved.
    func chooseTaskDayCalendarDay(_ day: Date) {
        guard let open = taskDayCalendar, open.calendar.takesChoice(of: day), choose(day, for: .task(open.taskID))
        else { return }
        taskDayCalendar?.calendar.choose(day)
    }

    func closeTaskDayCalendar() {
        guard let id = taskDayCalendar?.taskID else { return }
        taskDayCalendar = nil
        stopListing(id)
    }
}
