import Domain
import Foundation

/// Sample entries for SwiftUI previews of the widget.
extension UpcomingWidgetEntry {
    private static let previewNames = [
        "Buy oat milk", "Call mum", "Pay rent", "Walk the dog", "Water the plants",
        "Book a haircut", "Fix the bike", "Read a chapter", "Bake bread", "Wash the car", "Post the letter",
    ]

    /// The first `taskCount` sample Tasks, all on Today.
    static func preview(taskCount count: Int) -> UpcomingWidgetEntry {
        let today = Date.today
        let tasks = previewNames.prefix(count).enumerated().map { index, name in
            TodoTask(id: UUID(), name: name, day: today, completeDay: nil, sortIndex: index)
        }
        return UpcomingWidgetEntry(date: .now, content: UpcomingWidgetContent(tasks: tasks, today: today))
    }

    /// Long names on every kind of Day, so each marker meets a cut name.
    static func previewLongNames(count: Int) -> UpcomingWidgetEntry {
        let today = Date.today
        let days = [today.addingDays(-1), today, today.addingDays(1)]
        let tasks = (0..<count).map { index in
            TodoTask(
                id: UUID(),
                name: "Return the library books before Friday",
                day: days[index % days.count],
                completeDay: nil,
                sortIndex: index
            )
        }
        .sorted { $0.day < $1.day }
        return UpcomingWidgetEntry(date: .now, content: UpcomingWidgetContent(tasks: tasks, today: today))
    }

    /// The Tasks the repository returns with these settings, from a sample of Overdue, Today's and Tomorrow's Tasks.
    static func preview(showsOverdueTasks: Bool, showsTomorrowTasks: Bool) -> UpcomingWidgetEntry {
        let today = Date.today
        let tasks = [
            TodoTask(id: UUID(), name: "Pay rent", day: today.addingDays(-2), completeDay: nil, sortIndex: 0),
            TodoTask(id: UUID(), name: "Buy oat milk", day: today, completeDay: nil, sortIndex: 0),
            TodoTask(id: UUID(), name: "Call mum", day: today, completeDay: nil, sortIndex: 1),
            TodoTask(id: UUID(), name: "Water the plants", day: today.addingDays(1), completeDay: nil, sortIndex: 0),
        ]
        let listed = tasks.filter { task in
            switch task.day.relativeDay(today: today) {
            case .beforeToday: showsOverdueTasks
            case .today: true
            case .tomorrow: showsTomorrowTasks
            case .later: false
            }
        }
        return UpcomingWidgetEntry(date: .now, content: UpcomingWidgetContent(tasks: listed, today: today))
    }
}
