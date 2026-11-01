import Domain
import SwiftUI

/// A Day section's header in the Schedule.
struct DayHeaderView: View {
    let scheduleDay: Schedule.Day
    let today: Date
    let composerOpenerFocus: ComposerOpenerFocus
    /// Asks the owner to show the composer on this Day, to add a Task.
    let onAdd: () -> Void

    var body: some View {
        let header = scheduleDay.day.dayHeader(today: today)
        HStack {
            Text(header)
                .italic(scheduleDay.startsMonth)
                .underline(scheduleDay.startsMonth)
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus")
            }
            // Only the "+" takes the tap, not the whole header.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(.taskAddToDay(day: header)))
            .accessibilityFocused(returningTo: .day(scheduleDay.day), from: composerOpenerFocus)
        }
        .font(.subheadline.weight(scheduleDay.tasks.isEmpty ? .regular : .bold))
        // Colours, not the `.primary` and `.secondary` styles, which resolve against the header's grey.
        .foregroundStyle(scheduleDay.tasks.isEmpty ? Color.secondary : Color.primary)
        .textCase(nil)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let today = Date.today
    DayHeaderView(
        scheduleDay: Schedule(tasks: [.previewIncomplete], today: today).days[0],
        today: today,
        composerOpenerFocus: ComposerOpenerFocus()
    ) {}
}
