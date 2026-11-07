import Domain
import FactoryKit
import SwiftUI

/// The sheet that chooses a Day to move a Task to.
struct SheetDayPickerView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    @State private var listPosition = ScrollPosition(idType: DayPickerCalendar.Row.self)

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                if let sheetDayPicker = vm.sheetDayPicker {
                    content(sheetDayPicker)
                } else {
                    // Never shown: the picker's state outlives the sheet.
                    ProgressView()
                }
            }
            .toolbar {
                // Both in the tint: on iOS 26 a toolbar button's text is otherwise primary.
                ToolbarItem(placement: .cancellationAction) {
                    Button { vm.sheetDayPicker?.isVisible = false } label: {
                        Text(.sheetDayPickerCancel).foregroundStyle(.tint)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: vm.confirmSheetDayPicker) {
                        Text(.sheetDayPickerConfirm).foregroundStyle(
                            vm.sheetDayPicker?.chosenDay == nil ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.tint)
                        )
                    }
                    .disabled(vm.sheetDayPicker?.chosenDay == nil)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sensoryFeedback(.selection, trigger: vm.sheetDayPicker?.chosenDay) { _, chosenDay in chosenDay != nil }
    }

    // MARK: - UI Components
    private func content(_ sheetDayPicker: SheetDayPickerState) -> some View {
        let monthOffsets = sheetDayPicker.monthOffsets
        let calendar = DayPickerCalendar(
            today: sheetDayPicker.today, firstMonthOffset: monthOffsets.lowerBound, monthCount: monthOffsets.count
        )
        return VStack(spacing: 0) {
            weekdayRow(calendar)
            summaryLine(sheetDayPicker)
            Divider()
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(calendar.rows) { row in
                        switch row {
                        case let .monthHeader(firstDay): monthHeader(firstDay, today: sheetDayPicker.today)
                        case let .week(days): week(days, sheetDayPicker: sheetDayPicker)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 8)
            }
            .scrollPosition($listPosition, anchor: .center)
            .onAppear {
                if let row = calendar.weekRow(containing: sheetDayPicker.chosenDay ?? sheetDayPicker.today) {
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

    private func week(_ days: [Date?], sheetDayPicker: SheetDayPickerState) -> some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                Group {
                    if let day = days[index] {
                        PickerDayView(
                            day: day,
                            chosenDay: sheetDayPicker.chosenDay,
                            today: sheetDayPicker.today,
                            canChoose: sheetDayPicker.canChoose(day),
                            isInMonth: true,
                            incompleteTaskCount: vm.scheduleTasks.incompleteTaskCount(on: day),
                            rowHeight: PickerDayView.fullRowHeight
                        ) { vm.sheetDayPicker?.choose(day) }
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

    private func summaryLine(_ sheetDayPicker: SheetDayPickerState) -> some View {
        Group {
            if let day = sheetDayPicker.chosenDay {
                let incompleteTaskCount = vm.scheduleTasks.incompleteTaskCount(on: day)
                let taskCount = String(localized: .dayPickerTaskCount(count: incompleteTaskCount))
                Text(.sheetDayPickerSummary(
                    weekday: day.shortWeekday, day: day.shortDate(today: sheetDayPicker.today), taskCount: taskCount
                ))
            } else {
                Text(.sheetDayPickerPrompt)
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview(traits: .sampleTasks) {
    SheetDayPickerView()
        // The view resolves the same shared view model.
        .onAppear {
            let task = TodoTask.previewTomorrow
            Container.shared.scheduleViewModel().showSheetDayPicker(on: task.day, for: .task(task.id))
        }
}
