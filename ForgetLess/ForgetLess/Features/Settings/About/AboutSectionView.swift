import FactoryKit
import SwiftUI

/// The Settings screen's About section: the app's version, its pages on the web and the libraries it ships.
struct AboutSectionView: View {
    private static let privacyPolicyURL = URL(string: "https://diaus.github.io/forgetless/privacy/")!
    private static let supportURL = URL(string: "https://diaus.github.io/forgetless/support/")!

    @InjectedObservable(\.settingsViewModel) private var vm

    // MARK: - Body
    var body: some View {
        Section {
            versionRow
            WebLinkRowView(title: .settingsAboutPrivacyPolicy, destination: Self.privacyPolicyURL)
            WebLinkRowView(title: .settingsAboutSupport, destination: Self.supportURL)
            NavigationLink { LicensesView() } label: {
                Text(.settingsAboutLicenses)
            }
        } header: {
            Text(.settingsAbout)
        }
    }

    // MARK: - UI Components
    private var versionRow: some View {
        ValueRowView(title: .settingsAboutVersion, value: vm.appVersion)
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
}
