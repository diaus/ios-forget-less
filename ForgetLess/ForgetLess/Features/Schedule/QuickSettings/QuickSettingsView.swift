import FactoryKit
import SwiftUI

/// The quick settings bar above the Schedule.
struct QuickSettingsView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm

    var body: some View {
        HStack(spacing: 8) {
            Button { withAnimation { vm.showsHistory.toggle() } } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .quickSettingSquare(isFilled: vm.showsHistory)
            }
            .buttonStyle(.plain)
            .accessibilityRepresentation {
                Toggle(isOn: $vm.showsHistory.animation()) { Text(.scheduleHistory) }
            }
            Button { withAnimation { vm.showsComplete.toggle() } } label: {
                Image(systemName: vm.showsComplete ? "checklist.checked" : "checklist.unchecked")
                    .quickSettingSquare()
            }
            .buttonStyle(.plain)
            // A toggle for VoiceOver, with its on/off value; the glyph alone shows the state on screen.
            .accessibilityRepresentation {
                Toggle(isOn: $vm.showsComplete.animation()) { Text(.scheduleShowCompleteTasks) }
            }
            // History always lists Complete Tasks, so the choice can't change them there.
            .disabled(vm.showsHistory)
            NavigationLink { SettingsView() } label: {
                Image(systemName: "gearshape")
                    .quickSettingSquare()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(.settingsTitle))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

private extension View {
    /// Gives every quick setting the same face, filled where its glyph alone doesn't show it's on.
    @ViewBuilder
    func quickSettingSquare(isFilled: Bool = false) -> some View {
        let square = font(.body.weight(.medium))
            // Inverted on the fill, which is the primary colour.
            .foregroundStyle(isFilled ? Color(.systemBackground) : Color.primary)
            .frame(width: 36, height: 36)
            .contentShape(.rect(cornerRadius: 8))
        if #available(iOS 26, *) {
            square.glassEffect(.regular.tint(isFilled ? .primary : nil).interactive(), in: .rect(cornerRadius: 8))
        } else {
            // Not `.bordered`, which tints the square with the accent.
            square.background(
                isFilled ? AnyShapeStyle(.primary) : AnyShapeStyle(.fill.tertiary), in: .rect(cornerRadius: 8)
            )
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NavigationStack {
        QuickSettingsView()
    }
}
