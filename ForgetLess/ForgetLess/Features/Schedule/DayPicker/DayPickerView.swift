import Domain
import FactoryKit
import SwiftUI

/// The sheet that chooses a Day to move a Task to.
struct DayPickerView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    @State private var listPosition = ScrollPosition(idType: DayPickerCalendar.Row.self)

    /// How many months the picker offers, from Today's on.
    private static let monthCount = 60

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if let dayPicker = vm.dayPicker {
                    content(dayPicker)
                } else {
                    // Never shown: the picker's state outlives the sheet.
                    ProgressView()
                }
            }
            .toolbar {
                // Both in the tint: on iOS 26 a toolbar button's text is otherwise primary.
                ToolbarItem(placement: .cancellationAction) {
                    Button { vm.dayPicker?.isVisible = false } label: {
                        Text(.dayPickerCancel).foregroundStyle(.tint)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: vm.confirmDayPicker) {
                        Text(.dayPickerConfirm).foregroundStyle(
                            vm.dayPicker?.chosenDay == nil ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.tint)
                        )
                    }
                    .disabled(vm.dayPicker?.chosenDay == nil)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sensoryFeedback(.selection, trigger: vm.dayPicker?.chosenDay) { _, chosenDay in chosenDay != nil }
    }

    // MARK: - UI Components
    private func content(_ dayPicker: DayPickerState) -> some View {
        let calendar = DayPickerCalendar(today: dayPicker.today, monthCount: Self.monthCount)
        return VStack(spacing: 0) {
            weekdayRow(calendar)
            summaryLine(dayPicker)
            Divider()
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(calendar.rows) { row in
                        switch row {
                        case let .monthHeader(firstDay): monthHeader(firstDay, today: dayPicker.today)
                        case let .week(days): week(days, dayPicker: dayPicker)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 8)
            }
            .scrollPosition($listPosition, anchor: .center)
            .onAppear {
                if let row = calendar.weekRow(containing: dayPicker.chosenDay ?? dayPicker.today) {
                    listPosition.scrollTo(id: row, anchor: .center)
                }
            }
        }
    }

    private func monthHeader(_ firstDay: Date, today: Date) -> some View {
        Text(firstDay.monthName(today: today))
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.top, 16)
            .padding(.bottom, 4)
            // So the rotor moves by month.
            .accessibilityAddTraits(.isHeader)
    }

    private func week(_ days: [Date?], dayPicker: DayPickerState) -> some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                Group {
                    if let day = days[index] {
                        DayPickerDayView(
                            day: day,
                            isChosen: dayPicker.chosenDay == day,
                            canChoose: dayPicker.canChoose(day),
                            isToday: dayPicker.today == day,
                            incompleteTaskCount: vm.incompleteTaskCountsByDay[day] ?? 0,
                            rowHeight: DayPickerDayView.fullRowHeight
                        ) { vm.dayPicker?.choose(day) }
                    } else {
                        Color.clear.accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func weekdayRow(_ calendar: DayPickerCalendar) -> some View {
        HStack(spacing: 0) {
            ForEach(calendar.weekdays, id: \.self) { weekday in
                Text(weekday.shortWeekday)
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
    }

    private func summaryLine(_ dayPicker: DayPickerState) -> some View {
        Group {
            if let day = dayPicker.chosenDay {
                let taskCount = String(localized: .dayPickerTaskCount(count: vm.incompleteTaskCountsByDay[day] ?? 0))
                Text(.dayPickerSummary(
                    weekday: day.shortWeekday, day: day.shortDate(today: dayPicker.today), taskCount: taskCount
                ))
            } else {
                Text(.dayPickerPrompt)
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview(traits: .sampleTasks) {
    DayPickerView()
        // The view resolves the same shared view model.
        .onAppear { Container.shared.scheduleViewModel().showDayPicker(for: .previewTomorrow) }
}
