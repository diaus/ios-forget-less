import Domain
import Foundation
import SwiftData

/// The SwiftData `TodoTaskRepository`. Converts every Day between local start of day and its stored form with the
/// injected calendar (ADR 0001). The default follows the device's time zone as it changes, so a Day read after a
/// time-zone change comes back as local midnight of the new zone.
actor TodoTaskRepositoryLive: TodoTaskRepository, ModelActor {
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer
    private let calendar: Calendar

    init(modelContainer: ModelContainer, calendar: Calendar = .autoupdatingCurrent) {
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.modelContainer = modelContainer
        self.calendar = calendar
    }

    func tasks(on day: Date) throws -> [TodoTask] {
        let storedDay = DayEncoding.stored(day, calendar: calendar)
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day == storedDay })
        return try modelContext.fetch(descriptor).map { $0.toDomain(calendar: calendar) }
    }

    func tasks(onOrAfter day: Date) throws -> [TodoTask] {
        let storedDay = DayEncoding.stored(day, calendar: calendar)
        let descriptor = FetchDescriptor<TodoTaskModel>(predicate: #Predicate { $0.day >= storedDay })
        return try modelContext.fetch(descriptor).map { $0.toDomain(calendar: calendar) }
    }

    func create(_ task: TodoTask) throws {
        modelContext.insert(TodoTaskModel(task, calendar: calendar))
        try modelContext.save()
    }
}
