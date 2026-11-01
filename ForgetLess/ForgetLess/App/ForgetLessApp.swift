import Data
import FactoryKit
import SwiftUI
import WidgetKit

@main
struct ForgetLessApp: App {
    init() {
        // The widget can't observe the store, so every save reloads its timelines (ADR 0003).
        Container.shared.afterStoreSave.register { { WidgetCenter.shared.reloadAllTimelines() } }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScheduleView()
            }
        }
    }
}
