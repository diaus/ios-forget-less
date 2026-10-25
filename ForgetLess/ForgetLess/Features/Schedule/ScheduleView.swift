import SwiftUI

/// The app's one screen: the Today section, with the composer over it.
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
                Section {
                    ForEach(viewModel.todayTasks) { task in
                        TaskRowView(task: task)
                    }
                } header: {
                    Text(.dayToday)
                }
            }
            // Room under the last row, so the floating "+" never covers it.
            .contentMargins(.bottom, 88, for: .scrollContent)
            Button(action: showComposer) {
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

    // MARK: - Actions
    /// Shows the panel and focuses its field in one synchronous action, so the keyboard starts in the same frame.
    private func showComposer() {
        viewModel.showComposer()
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
