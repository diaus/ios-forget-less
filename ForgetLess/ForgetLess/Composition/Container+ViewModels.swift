import FactoryKit

/// View models, one `@MainActor var` Factory each.
/// `.shared`, so a screen's subviews resolve the instance the screen holds.
extension Container {
    @MainActor var scheduleViewModel: Factory<ScheduleViewModel> {
        self { @MainActor in ScheduleViewModel() }.shared
    }
}
