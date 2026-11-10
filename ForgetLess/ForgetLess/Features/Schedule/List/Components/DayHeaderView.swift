import Domain
import FactoryKit
import SwiftUI

/// A Day section's header in the Schedule.
struct DayHeaderView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let scheduleDay: Schedule.Day

    var body: some View {
        let header = scheduleDay.day.dayHeader(today: vm.today)
        HStack {
            Text(header)
                .italic(scheduleDay.startsMonth)
                .underline(scheduleDay.startsMonth)
            Spacer()
            Button { vm.composerSession.show(on: scheduleDay.day, from: .day(scheduleDay.day)) } label: {
                Image(systemName: "plus")
            }
            // Only the "+" takes the tap, not the whole header.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(.taskAddToDay(day: header)))
            .accessibilityFocused(returningTo: .day(scheduleDay.day))
        }
        .font(.subheadline.weight(scheduleDay.tasks.isEmpty ? .regular : .bold))
        // Colours, not the `.primary` and `.secondary` styles, which resolve against the header's grey.
        .foregroundStyle(scheduleDay.tasks.isEmpty ? Color.secondary : Color.primary)
        .textCase(nil)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    DayHeaderView(scheduleDay: Schedule(tasks: [.previewIncomplete], today: .today, now: .now).days[0])
}
