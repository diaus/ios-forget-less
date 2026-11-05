import Domain
import SwiftUI

/// A Day in a month to choose a Day from, chosen by a tap.
struct PickerDayView: View {
    let day: Date
    /// The Day chosen so far, if any.
    let chosenDay: Date?
    let today: Date
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
        let size = rowHeight - 2 * rowPadding
        Button(action: onChoose) {
            ZStack {
                if isChosen {
                    Circle().fill(.tint)
                }
                Text(day.dayOfMonth)
                    .font(.body.weight(isToday ? .semibold : .regular))
                    // Shrinks with a short row, so every Day still shows.
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .foregroundStyle(numberStyle)
                // Under the number, inside the chosen Day's circle, however small the row.
                Circle()
                    .fill(isChosen ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
                    .frame(width: 5, height: 5)
                    .offset(y: size * 0.3)
                    .opacity(incompleteTaskCount > 0 ? (canChoose ? 1 : 0.4) : 0)
            }
            .frame(width: size, height: size)
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
    private var isChosen: Bool {
        day == chosenDay
    }

    private var canChoose: Bool {
        day.canBePlanned(today: today)
    }

    private var isToday: Bool {
        day == today
    }

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
    let today = Date.today
    HStack {
        ForEach(-1..<3, id: \.self) { dayCount in
            PickerDayView(
                day: today.addingDays(dayCount), chosenDay: today.addingDays(1), today: today, isInMonth: dayCount < 2,
                incompleteTaskCount: 1, rowHeight: PickerDayView.fullRowHeight
            ) {}
        }
    }
}
