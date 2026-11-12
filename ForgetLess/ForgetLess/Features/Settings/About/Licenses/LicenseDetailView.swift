import FactoryKit
import SwiftUI

/// A library's page, opened from the Open Source Licenses screen.
struct LicenseDetailView: View {
    let license: OpenSourceLicense

    @InjectedObservable(\.licensesViewModel) private var vm

    var body: some View {
        List {
            Section {
                ValueRowView(title: .settingsAboutVersion, value: license.version)
                ValueRowView(title: .settingsAboutLicensesLicense, value: license.license)
                WebLinkRowView(title: .settingsAboutLicensesRepository, destination: license.repositoryURL)
            }
            Section {
                Text(vm.text(of: license))
                    .textSelection(.enabled)
            }
        }
        .navigationTitle(Text(license.name))
        .navigationBarTitleDisplayMode(.inline)
    }
}
