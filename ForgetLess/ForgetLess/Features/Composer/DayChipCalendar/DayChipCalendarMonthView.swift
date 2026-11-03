import Domain
import FactoryKit
import SwiftUI

/// A month of the Day chip calendar.
struct DayChipCalendarMonthView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let month: DayPickerCalendar.Month
    let calendar: DayChipCalendarState
    let rowHeight: CGFloat
    /// Reports the height above the weeks, which the calendar fits its rows around.
    let onHeaderHeightChange: (CGFloat) -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                header
                weekdayRow(DayPickerCalendar.weekdays())
            }
            .onGeometryChange(for: CGFloat.self, of: \.size.height, action: onHeaderHeightChange)
            ForEach(month.weeks(count: DayChipCalendarLayout.weekCount), id: \.self, content: week)
        }
    }

    // MARK: - UI Components
    private var header: some View {
        Text(month.firstDay.monthName(today: calendar.today))
            .font(.headline)
            // One line at any text size, so the weeks keep the height.
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            // Clear of the ✕ over the page's top-trailing corner.
            .padding(.trailing, DayChipCalendarView.closeButtonSize)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
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
                DayPickerDayView(
                    day: day,
                    isChosen: calendar.chosenDay == day,
                    canChoose: calendar.canChoose(day),
                    isToday: calendar.today == day,
                    isInMonth: day.isInSameMonth(as: month.firstDay),
                    incompleteTaskCount: vm.incompleteTaskCountsByDay[day] ?? 0,
                    rowHeight: rowHeight
                ) { vm.chooseDayChipCalendarDay(day) }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
