import Domain
import SwiftUI

/// The nearest Days, one tap away from any month of the floating Day picker.
struct FloatingDayPickerButtonsView: View {
    let picker: FloatingDayPickerState
    let onChoose: (Date) -> Void

    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            ForEach(picker.buttonDays, id: \.self, content: button)
        }
    }

    // MARK: - UI Components
    private func button(_ day: Date) -> some View {
        // A tap on the button is a tap on its Day, so there's one rule to learn.
        Button { onChoose(day) } label: {
            Text(day.dayChipLabel(today: picker.today))
                .font(.subheadline)
                .foregroundStyle(day.dayChipColor(today: picker.today))
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
