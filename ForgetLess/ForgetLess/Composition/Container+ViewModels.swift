import FactoryKit

/// Factories for the view models.
extension Container {
    @MainActor var scheduleViewModel: Factory<ScheduleViewModel> {
        // Shared, so a screen's subviews resolve the instance the screen holds.
        self { @MainActor in ScheduleViewModel() }.shared
    }
}
