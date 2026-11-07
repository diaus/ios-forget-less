import Domain
import FactoryKit
import SwiftUI

/// A month of the floating Day picker.
struct FloatingDayPickerMonthView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let month: DayPickerCalendar.Month
    /// How many months `month` is after Today's month.
    let offset: Int
    let picker: FloatingDayPickerState
    let rowHeight: CGFloat
    var focusedMonthOffset: AccessibilityFocusState<Int?>.Binding
    /// Asks to page by a number of months.
    let onPage: (_ monthCount: Int) -> Void
    let onChoose: (Date) -> Void
    /// Reports the height above the weeks, which the picker fits its rows around.
    let onHeaderHeightChange: (CGFloat) -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                header
                weekdayRow(DayPickerCalendar.weekdays())
            }
            .onGeometryChange(for: CGFloat.self, of: \.size.height, action: onHeaderHeightChange)
            ForEach(month.weeks(count: FloatingDayPickerLayout.weekCount), id: \.self, content: week)
        }
    }

    // MARK: - UI Components
    private var header: some View {
        Text(month.firstDay.monthName(today: picker.today))
            .font(.headline)
            // One line at any text size, so the weeks keep the height.
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            // Clear of the ✕ over the page's top-trailing corner.
            .padding(.trailing, FloatingDayPickerView.closeButtonSize)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            // For VoiceOver, which can't swipe sideways to page: swiping up or down pages instead.
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: onPage(1)
                case .decrement: onPage(-1)
                @unknown default: break
                }
            }
            .accessibilityFocused(focusedMonthOffset, equals: offset)
    }

    private func weekdayRow(_ weekdays: [Date]) -> some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday.shortWeekday)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.bottom, 4)
    }

    private func week(_ days: [Date]) -> some View {
        HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                PickerDayView(
                    day: day,
                    chosenDay: picker.chosenDay,
                    today: picker.today,
                    canChoose: picker.canChoose(day),
                    isInMonth: day.isInSameMonth(as: month.firstDay),
                    incompleteTaskCount: vm.scheduleTasks.incompleteTaskCount(on: day),
                    rowHeight: rowHeight
                ) { onChoose(day) }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
