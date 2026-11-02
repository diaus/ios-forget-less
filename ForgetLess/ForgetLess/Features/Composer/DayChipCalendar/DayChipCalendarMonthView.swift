import Domain
import FactoryKit
import SwiftUI

/// A month of the Day chip calendar.
struct DayChipCalendarMonthView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    let month: DayPickerCalendar.Month
    let calendar: DayChipCalendarState

    /// As many weeks as the longest month spans, so every month is as tall.
    private static let weekCount = 6

    // MARK: - Body
    var body: some View {
        let weekdays = DayPickerCalendar.weekdays()
        let blankWeek = [Date?](repeating: nil, count: weekdays.count)
        VStack(spacing: 0) {
            header
            weekdayRow(weekdays)
            ForEach(0..<Self.weekCount, id: \.self) { index in
                week(index < month.weeks.count ? month.weeks[index] : blankWeek)
            }
        }
    }

    // MARK: - UI Components
    private var header: some View {
        Text(month.firstDay.monthName(today: calendar.today))
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
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

    private func week(_ days: [Date?]) -> some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                Group {
                    if let day = days[index] {
                        DayPickerDayView(
                            day: day,
                            isChosen: calendar.chosenDay == day,
                            canChoose: calendar.canChoose(day),
                            isToday: calendar.today == day,
                            incompleteTaskCount: vm.incompleteTaskCountsByDay[day] ?? 0,
                            rowHeight: DayPickerDayView.fullRowHeight
                        ) { vm.chooseDayChipCalendarDay(day) }
                    } else {
                        Color.clear.accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        // A week of blanks has no Day to give it its height.
        .frame(height: DayPickerDayView.fullRowHeight)
    }
}
