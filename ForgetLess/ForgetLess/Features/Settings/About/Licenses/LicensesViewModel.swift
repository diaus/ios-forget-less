import Foundation
import Observation

/// Drives the Open Source Licenses screens.
@MainActor @Observable
final class LicensesViewModel {
    /// The libraries the app ships, sorted by name.
    let licenses: [OpenSourceLicense]
    private let texts: [OpenSourceLicense.ID: String]

    init() {
        // The manifest and texts ship in the bundle, so a missing or unreadable one is a programmer error.
        do {
            let licenses = try Self.loadManifest()
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            texts = try Dictionary(uniqueKeysWithValues: licenses.map { license in
                (license.id, Self.reflowed(try Self.loadText(of: license)))
            })
            self.licenses = licenses
        } catch {
            assertionFailure("Can't load the open source licenses: \(error)")
            licenses = []
            texts = [:]
        }
    }

    // MARK: - Detail
    /// The library's license text, reflowed for display. Empty for a library not in `licenses`.
    func text(of license: OpenSourceLicense) -> String {
        texts[license.id] ?? ""
    }

    // MARK: - Helpers
    private enum LoadError: Error {
        case missingFile(String)
    }

    private static func loadManifest() throws -> [OpenSourceLicense] {
        try JSONDecoder().decode([OpenSourceLicense].self, from: Data(contentsOf: bundleURL(of: "licenses.json")))
    }

    private static func loadText(of license: OpenSourceLicense) throws -> String {
        try String(contentsOf: bundleURL(of: license.file), encoding: .utf8)
    }

    private static func bundleURL(of file: String) throws -> URL {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            throw LoadError.missingFile(file)
        }
        return url
    }

    // Hard-wrapped text would break into ragged half-lines, so it's rewrapped to the screen's width instead.
    private static func reflowed(_ text: String) -> String {
        var paragraphs: [String] = []
        var lines: [String] = []
        for line in text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline) {
            let line = line.trimmingCharacters(in: .whitespaces)
            if !line.isEmpty {
                lines.append(line)
            } else if !lines.isEmpty {
                paragraphs.append(lines.joined(separator: " "))
                lines = []
            }
        }
        if !lines.isEmpty {
            paragraphs.append(lines.joined(separator: " "))
        }
        return paragraphs.joined(separator: "\n\n")
    }
}
