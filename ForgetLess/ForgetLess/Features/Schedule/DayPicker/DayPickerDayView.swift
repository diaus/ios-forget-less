import Domain
import FactoryKit
import SwiftUI

/// A Day in the Day picker, chosen by a tap.
struct DayPickerDayView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let day: Date

    /// The size of the chosen Day's circle.
    private let circleSize: CGFloat = 44

    // MARK: - Body
    var body: some View {
        let isChosen = vm.dayPicker?.chosenDay == day
        let canChoose = vm.dayPicker?.canChoose(day) ?? false
        let isToday = vm.dayPicker?.today == day
        let incompleteTaskCount = vm.incompleteTaskCountsByDay[day] ?? 0
        Button { vm.dayPicker?.choose(day) } label: {
            ZStack {
                if isChosen {
                    Circle().fill(.tint)
                }
                Text(day.dayOfMonth)
                    .font(.body.weight(isToday ? .semibold : .regular))
                    .foregroundStyle(numberStyle(isChosen: isChosen, isToday: isToday, canChoose: canChoose))
                // Under the number, inside the chosen Day's circle.
                Circle()
                    .fill(isChosen ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
                    .frame(width: 5, height: 5)
                    .offset(y: 13)
                    .opacity(incompleteTaskCount > 0 ? (canChoose ? 1 : 0.4) : 0)
            }
            .frame(width: circleSize, height: circleSize)
            .padding(.vertical, 3)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!canChoose)
        .accessibilityLabel(day.fullDate)
        .accessibilityValue(Text(.dayPickerTaskCount(count: incompleteTaskCount)))
        .accessibilityAddTraits(isChosen ? .isSelected : [])
    }

    // MARK: - Helpers
    private func numberStyle(isChosen: Bool, isToday: Bool, canChoose: Bool) -> AnyShapeStyle {
        if !canChoose {
            AnyShapeStyle(.tertiary)
        } else if isChosen {
            AnyShapeStyle(.white)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else {
            AnyShapeStyle(.primary)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HStack {
        DayPickerDayView(day: Date.today.addingDays(-1))
        DayPickerDayView(day: .today)
        DayPickerDayView(day: Date.today.addingDays(1))
    }
    // The view resolves the same shared view model.
    .onAppear { Container.shared.scheduleViewModel().showDayPicker(for: .previewTomorrow) }
}
