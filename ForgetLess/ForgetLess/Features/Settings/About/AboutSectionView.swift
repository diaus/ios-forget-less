import FactoryKit
import SwiftUI

/// The Settings screen's About section: the app's version and its pages on the web.
struct AboutSectionView: View {
    private static let privacyPolicyURL = URL(string: "https://diaus.github.io/forgetless/privacy/")!
    private static let supportURL = URL(string: "https://diaus.github.io/forgetless/support/")!

    @InjectedObservable(\.settingsViewModel) private var vm

    // MARK: - Body
    var body: some View {
        Section {
            versionRow
            linkRow(.settingsAboutPrivacyPolicy, destination: Self.privacyPolicyURL)
            linkRow(.settingsAboutSupport, destination: Self.supportURL)
        } header: {
            Text(.settingsAbout)
        }
    }

    // MARK: - UI Components
    private var versionRow: some View {
        LabeledContent {
            Text(vm.appVersion)
        } label: {
            Text(.settingsAboutVersion)
        }
        // One element, so VoiceOver reads the title with its value.
        .accessibilityElement(children: .combine)
        .contextMenu {
            Button(action: vm.copyAppVersion) {
                Label {
                    Text(.settingsAboutCopy)
                } icon: {
                    Image(systemName: "doc.on.doc")
                }
            }
        }
    }

    private func linkRow(_ title: LocalizedStringResource, destination: URL) -> some View {
        Link(destination: destination) {
            HStack {
                Text(title)
                    // `Color`, not the hierarchical style: inside a `Link` that resolves to the accent tint.
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .foregroundStyle(Color.secondary)
                    .accessibilityHidden(true)
            }
        }
    }
}
