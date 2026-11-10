import Domain
import Foundation

/// Sample entries for SwiftUI previews of the widget.
extension UpcomingWidgetEntry {
    private static let previewNames = [
        "Buy oat milk", "Call mum", "Pay rent", "Walk the dog", "Water the plants",
        "Book a haircut", "Fix the bike", "Read a chapter", "Bake bread", "Wash the car", "Post the letter",
    ]

    /// The first `taskCount` sample Tasks, all on Today, listing at most `rowLimit` of them, or all when it's nil.
    /// Past the sample's names, they repeat.
    static func preview(
        taskCount count: Int,
        rowLimit: Int? = UpcomingWidgetContent.maxRowCount
    ) -> UpcomingWidgetEntry {
        let today = Date.today
        let tasks = (0..<count).map { index in
            TodoTask(
                id: UUID(),
                name: previewNames[index % previewNames.count],
                day: today,
                completeDay: nil,
                sortIndex: index
            )
        }
        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: false, rowLimit: rowLimit)
        return UpcomingWidgetEntry(date: .now, content: content)
    }

    /// `overdueCount` Overdue Tasks, then `todayCount` of Today's and `tomorrowCount` of Tomorrow's, listing at most
    /// `rowLimit` of them, or all when it's nil.
    static func preview(
        overdueCount: Int,
        todayCount: Int,
        tomorrowCount: Int,
        rowLimit: Int? = UpcomingWidgetContent.maxRowCount,
        showsLeftOutCount: Bool = true,
        showsMoveArrows: Bool = true
    ) -> UpcomingWidgetEntry {
        let today = Date.today
        let days = Array(repeating: today.addingDays(-1), count: overdueCount)
            + Array(repeating: today, count: todayCount)
            + Array(repeating: today.addingDays(1), count: tomorrowCount)
        let tasks = days.enumerated().map { index, day in
            TodoTask(
                id: UUID(),
                name: previewNames[index % previewNames.count],
                day: day,
                completeDay: nil,
                sortIndex: index
            )
        }
        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true, rowLimit: rowLimit)
        return UpcomingWidgetEntry(
            date: .now,
            content: content,
            showsLeftOutCount: showsLeftOutCount,
            showsMoveArrows: showsMoveArrows
        )
    }

    /// Long names on every kind of Day, so each marker meets a cut name.
    static func previewLongNames(count: Int, cutEnding: CutEnding = .verticalEllipsis) -> UpcomingWidgetEntry {
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
        let content = UpcomingWidgetContent(tasks: tasks, today: today, listsTomorrow: true)
        return UpcomingWidgetEntry(date: .now, content: content, cutEnding: cutEnding)
    }

    /// The Tasks the repository returns with these settings, from a sample of Overdue, Today's and Tomorrow's Tasks.
    static func preview(
        showsOverdueTasks: Bool,
        showsTomorrowTasks: Bool,
        rowLimit: Int? = UpcomingWidgetContent.maxRowCount
    ) -> UpcomingWidgetEntry {
        let today = Date.today
        let tasks = [
            TodoTask(id: UUID(), name: "Pay rent", day: today.addingDays(-2), completeDay: nil, sortIndex: 0),
            TodoTask(id: UUID(), name: "Buy oat milk", day: today, completeDay: nil, sortIndex: 0),
            TodoTask(id: UUID(), name: "Call mum", day: today, completeDay: nil, sortIndex: 1),
            TodoTask(id: UUID(), name: "Water the plants", day: today.addingDays(1), completeDay: nil, sortIndex: 0),
        ]
        let listed = tasks.filter { task in
            switch task.day.relativeDay(today: today) {
            case .beforeToday, .yesterday: showsOverdueTasks
            case .today: true
            case .tomorrow: showsTomorrowTasks
            case .later: false
            }
        }
        return UpcomingWidgetEntry(
            date: .now,
            content: UpcomingWidgetContent(
                tasks: listed,
                today: today,
                listsTomorrow: showsTomorrowTasks,
                rowLimit: rowLimit
            )
        )
    }
}
