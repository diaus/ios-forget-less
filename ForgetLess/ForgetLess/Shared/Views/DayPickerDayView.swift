import Domain
import SwiftUI

/// A Day in a month to choose a Day from, chosen by a tap.
struct DayPickerDayView: View {
    let day: Date
    let isChosen: Bool
    let canChoose: Bool
    let isToday: Bool
    /// Whether `day` is in the month shown, rather than a Day of the months either side.
    let isInMonth: Bool
    let incompleteTaskCount: Int
    /// The height of the week row the Day sits in.
    let rowHeight: CGFloat
    let onChoose: () -> Void

    /// A row's height in the Choose a Day sheet.
    static let fullRowHeight: CGFloat = 50

    private let rowPadding: CGFloat = 3

    // MARK: - Body
    var body: some View {
        Button(action: onChoose) {
            ZStack {
                if isChosen {
                    Circle().fill(.tint)
                }
                Text(day.dayOfMonth)
                    .font(.body.weight(isToday ? .semibold : .regular))
                    .foregroundStyle(numberStyle)
                // Under the number, inside the chosen Day's circle.
                Circle()
                    .fill(isChosen ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
                    .frame(width: 5, height: 5)
                    .offset(y: 13)
                    .opacity(incompleteTaskCount > 0 ? (canChoose ? 1 : 0.4) : 0)
            }
            .frame(width: rowHeight - 2 * rowPadding, height: rowHeight - 2 * rowPadding)
            .padding(.vertical, rowPadding)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!canChoose)
        .accessibilityLabel(day.fullDate)
        .accessibilityValue(Text(.dayPickerTaskCount(count: incompleteTaskCount)))
        .accessibilityAddTraits(isChosen ? .isSelected : [])
    }

    // MARK: - Helpers
    private var numberStyle: AnyShapeStyle {
        if !canChoose {
            AnyShapeStyle(.tertiary)
        } else if isChosen {
            AnyShapeStyle(.white)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else if !isInMonth {
            AnyShapeStyle(Color(.dayPickerOtherMonthDay))
        } else {
            AnyShapeStyle(.primary)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HStack {
        DayPickerDayView(
            day: Date.today.addingDays(-1), isChosen: false, canChoose: false, isToday: false, isInMonth: true,
            incompleteTaskCount: 1, rowHeight: DayPickerDayView.fullRowHeight
        ) {}
        DayPickerDayView(
            day: .today, isChosen: false, canChoose: true, isToday: true, isInMonth: true,
            incompleteTaskCount: 2, rowHeight: DayPickerDayView.fullRowHeight
        ) {}
        DayPickerDayView(
            day: Date.today.addingDays(1), isChosen: true, canChoose: true, isToday: false, isInMonth: true,
            incompleteTaskCount: 1, rowHeight: DayPickerDayView.fullRowHeight
        ) {}
        DayPickerDayView(
            day: Date.today.addingDays(2), isChosen: false, canChoose: true, isToday: false, isInMonth: false,
            incompleteTaskCount: 1, rowHeight: DayPickerDayView.fullRowHeight
        ) {}
    }
}
