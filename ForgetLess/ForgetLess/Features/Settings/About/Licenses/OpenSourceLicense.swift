import Foundation

/// A library the app ships, as `Resources/Licenses/licenses.json` lists it.
struct OpenSourceLicense: Decodable, Identifiable {
    let name: String
    let version: String
    /// The license's short name, such as "MIT".
    let license: String
    let repositoryURL: URL
    /// The name of the license text's file, beside the manifest.
    let file: String

    var id: String { name }
}
