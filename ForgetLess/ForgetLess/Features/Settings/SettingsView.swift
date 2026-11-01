import FactoryKit
import SwiftUI

/// The Settings screen.
struct SettingsView: View {
    @InjectedObservable(\.settingsViewModel) private var vm

    // MARK: - Body
    var body: some View {
        List {
            Section {
                keptDurationRow
            } footer: {
                Text(.settingsKeptDurationFooter)
            }
        }
        .navigationTitle(Text(.settingsTitle))
        .alert(
            Text(.settingsKeptDuration),
            isPresented: $vm.keptDurationEditor.isVisible,
            actions: keptDurationAlertActions,
            message: keptDurationAlertMessage
        )
    }

    // MARK: - Kept Duration
    @ViewBuilder
    private func keptDurationAlertActions() -> some View {
        TextField(text: $vm.keptDurationEditor.text, prompt: Text(.settingsSeconds)) { Text(.settingsSeconds) }
            .keyboardType(.decimalPad)
        Button(role: .cancel) {} label: { Text(.settingsCancel) }
        Button(action: vm.saveKeptDuration) { Text(.settingsSave) }
            .disabled(!vm.keptDurationEditor.canSave)
    }

    private func keptDurationAlertMessage() -> some View {
        let range = KeptDurationEditorState.range
        return Text(.settingsKeptDurationRange(min: Int(range.lowerBound), max: Int(range.upperBound)))
    }

    private var keptDurationRow: some View {
        LabeledContent {
            HStack(spacing: 12) {
                Text(keptDurationText)
                Button(action: vm.editKeptDuration) {
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                }
                // Borderless, so only the icon takes the tap, not the whole row.
                .buttonStyle(.borderless)
                .accessibilityLabel(Text(.settingsEdit))
            }
        } label: {
            Text(.settingsKeptDuration)
        }
    }

    private var keptDurationText: String {
        Measurement(value: vm.keptDuration, unit: UnitDuration.seconds)
            .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0...2))))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
