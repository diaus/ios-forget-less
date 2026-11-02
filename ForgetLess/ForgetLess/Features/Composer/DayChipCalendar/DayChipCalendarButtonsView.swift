import Domain
import FactoryKit
import SwiftUI

/// The nearest Days, one tap away from any month of the Day chip calendar.
struct DayChipCalendarButtonsView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let calendar: DayChipCalendarState

    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            ForEach(calendar.buttonDays, id: \.self, content: button)
        }
    }

    // MARK: - UI Components
    private func button(_ day: Date) -> some View {
        // A tap on the button is a tap on its Day, so there's one rule to learn.
        Button { vm.chooseDayChipCalendarDay(day) } label: {
            Text(day.dayChipLabel(today: calendar.today))
                .font(.subheadline)
                .foregroundStyle(day.dayChipColor(today: calendar.today))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.fill.tertiary, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}
