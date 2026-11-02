import Domain
import FactoryKit
import SwiftUI

/// A month of the Day chip calendar.
struct DayChipCalendarMonthView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let month: DayPickerCalendar.Month
    let calendar: DayChipCalendarState

    /// Every month as many weeks, so paging never changes the calendar's height.
    private static let weekCount = 5

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            weekdayRow(DayPickerCalendar.weekdays())
            ForEach(month.weeks(count: Self.weekCount), id: \.self, content: week)
        }
    }

    // MARK: - UI Components
    private var header: some View {
        Text(month.firstDay.monthName(today: calendar.today))
            .font(.headline)
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
                    rowHeight: DayPickerDayView.fullRowHeight
                ) { vm.chooseDayChipCalendarDay(day) }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
