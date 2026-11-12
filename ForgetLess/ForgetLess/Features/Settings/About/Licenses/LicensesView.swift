import FactoryKit
import SwiftUI

/// The Open Source Licenses screen: the libraries the app ships.
struct LicensesView: View {
    @InjectedObservable(\.licensesViewModel) private var vm

    // MARK: - Body
    var body: some View {
        List(vm.licenses) { license in
            NavigationLink { LicenseDetailView(license: license) } label: {
                row(for: license)
            }
        }
        .navigationTitle(Text(.settingsAboutLicenses))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - UI Components
    private func row(for license: OpenSourceLicense) -> some View {
        LabeledContent {
            Text(license.license)
        } label: {
            Text(license.name)
            // A second label text is the row's subtitle, in the secondary style.
            Text(license.version)
        }
        // One element, so VoiceOver reads the name with the version and the license.
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        LicensesView()
    }
}
