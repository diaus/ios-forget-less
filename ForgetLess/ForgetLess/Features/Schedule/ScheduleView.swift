import Domain
import SwiftUI

/// The app's one screen: a section per Day of the Schedule, with the composer over it.
struct ScheduleView: View {
    @State private var viewModel = ScheduleViewModel()
    @FocusState private var isComposerNameFocused: Bool

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .ignoresSafeArea(.keyboard)
            Color.black.opacity(viewModel.composer.isVisible ? 0.3 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(viewModel.composer.isVisible)
                .onTapGesture(perform: dismissComposer)
                .animation(.easeOut(duration: 0.2), value: viewModel.composer.isVisible)
            ComposerView(
                isVisible: viewModel.composer.isVisible,
                isNameFocused: $isComposerNameFocused,
                taskName: $viewModel.composer.taskName,
                day: viewModel.composer.day,
                today: viewModel.today,
                canSubmit: viewModel.composer.canSubmit,
                onSubmit: viewModel.submitComposer,
                onDismiss: dismissComposer
            )
        }
        .task { await viewModel.load() }
        .errorAlert(message: $viewModel.errorMessage)
    }

    // MARK: - UI Components
    private var content: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach(viewModel.schedule.days) { scheduleDay in
                    Section {
                        ForEach(scheduleDay.tasks) { task in
                            TaskRowView(task: task)
                        }
                    } header: {
                        dayHeader(scheduleDay)
                    }
                }
            }
            // Room under the last row, so the floating "+" never covers it.
            .contentMargins(.bottom, 88, for: .scrollContent)
            Button { showComposer(on: viewModel.today) } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.tint, in: .circle)
            }
            .accessibilityLabel(Text(.taskAdd))
            .padding(20)
        }
    }

    /// The Day's date and weekday with its "+": bold primary when the Day has any Task, grey when it has none.
    private func dayHeader(_ scheduleDay: Schedule.Day) -> some View {
        let header = scheduleDay.day.dayHeader(today: viewModel.today)
        return HStack {
            Text(header)
            Spacer()
            Button { showComposer(on: scheduleDay.day) } label: {
                Image(systemName: "plus")
            }
            // Only the "+" takes the tap, not the whole header.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text(.taskAddToDay(day: header)))
        }
        .font(.subheadline.weight(scheduleDay.tasks.isEmpty ? .regular : .bold))
        .foregroundStyle(scheduleDay.tasks.isEmpty ? .secondary : .primary)
        .textCase(nil)
    }

    // MARK: - Actions
    /// Shows the panel and focuses its field in one synchronous action, so the keyboard starts in the same frame.
    private func showComposer(on day: Date) {
        viewModel.showComposer(on: day)
        isComposerNameFocused = true
    }

    private func dismissComposer() {
        viewModel.dismissComposer()
        isComposerNameFocused = false
    }
}

#Preview {
    ScheduleView()
}
