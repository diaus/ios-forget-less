import FactoryKit
import SwiftUI

/// The quick settings bar above the Schedule.
struct QuickSettingsView: View {
    @InjectedObservable(\.scheduleViewModel) private var vm

    var body: some View {
        HStack(spacing: 8) {
            Button { withAnimation { vm.showsComplete.toggle() } } label: {
                Image(systemName: vm.showsComplete ? "checklist.checked" : "checklist.unchecked")
                    .quickSettingSquare()
            }
            .buttonStyle(.plain)
            // A toggle for VoiceOver, with its on/off value; the glyph alone shows the state on screen.
            .accessibilityRepresentation {
                Toggle(isOn: $vm.showsComplete.animation()) { Text(.scheduleShowCompleteTasks) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

private extension View {
    /// Gives every quick setting the same face, on or off.
    @ViewBuilder
    func quickSettingSquare() -> some View {
        let square = font(.body.weight(.medium))
            .foregroundStyle(.primary)
            .frame(width: 36, height: 36)
            .contentShape(.rect(cornerRadius: 8))
        if #available(iOS 26, *) {
            square.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 8))
        } else {
            // Not `.bordered`, which tints the square with the accent.
            square.background(.fill.tertiary, in: .rect(cornerRadius: 8))
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    QuickSettingsView()
}
