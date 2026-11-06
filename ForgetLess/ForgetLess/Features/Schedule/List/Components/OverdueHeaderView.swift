import FactoryKit
import SwiftUI

/// The Overdue section's header in the Schedule.
struct OverdueHeaderView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm
    /// Whether it offers to Move every Overdue Task: only while one is Incomplete.
    let showsMoveAll: Bool
    /// Asks the list to show the floating Day picker for the Overdue Tasks: only the list knows where the header is on
    /// screen, which the picker grows from.
    let onChooseDay: () -> Void

    // MARK: - Body
    var body: some View {
        // No "+": a Task can't be planned in the past.
        HStack {
            Text(.scheduleOverdue)
                .font(.subheadline.bold())
                // A colour, not the `.primary` style, which resolves against the header's grey.
                .foregroundStyle(Color.primary)
            Spacer()
            if showsMoveAll {
                moveAllButton
            }
        }
        .textCase(nil)
    }

    // MARK: - UI Components
    private var moveAllButton: some View {
        Button(action: onChooseDay) {
            Text(.scheduleOverdueMoveAll)
        }
        .buttonStyle(MoveAllButtonStyle(isPickerOpen: vm.floatingDayPicker?.target == .overdueTasks))
        .dayPickerLongPress(vm.showOverdueSheetDayPicker)
        .accessibilityHint(Text(.scheduleOverdueMoveAllHint))
        // VoiceOver's way to the long press, which it can't make.
        .accessibilityAction(named: Text(.taskChooseDay), vm.showOverdueSheetDayPicker)
    }
}

/// The Move All label, highlighted while it's touched and while its floating Day picker is open, as a row is while
/// its own is open.
private struct MoveAllButtonStyle: ButtonStyle {
    let isPickerOpen: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundStyle(.tint)
            .background {
                if configuration.isPressed || isPickerOpen {
                    // Past the label, so the header keeps its height and the label its place as the label comes and
                    // goes.
                    Capsule()
                        .fill(Color(.taskRowHighlight))
                        .padding(.horizontal, -8)
                        .padding(.vertical, -2)
                }
            }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    OverdueHeaderView(showsMoveAll: true) {}
}
