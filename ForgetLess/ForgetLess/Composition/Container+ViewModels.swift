import FactoryKit

/// Factories for the view models.
extension Container {
    @MainActor var scheduleViewModel: Factory<ScheduleViewModel> {
        // Shared, so a screen's subviews resolve the instance the screen holds.
        self { @MainActor in ScheduleViewModel() }.shared
    }

    @MainActor var settingsViewModel: Factory<SettingsViewModel> {
        // Shared, so a screen's subviews resolve the instance the screen holds.
        self { @MainActor in SettingsViewModel() }.shared
    }

    @MainActor var licensesViewModel: Factory<LicensesViewModel> {
        // Shared, so a library's page resolves the instance the list holds.
        self { @MainActor in LicensesViewModel() }.shared
    }
}
