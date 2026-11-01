import Foundation
import Utils

/// What the kept duration editor shows.
struct KeptDurationEditorState {
    /// The kept durations, in seconds, the editor saves.
    static let range = 0.0...30.0

    var isVisible = false
    var text: String
    /// Reads and writes `text`'s decimal separator.
    let locale: Locale

    /// An editor filled in with `seconds`.
    init(seconds: Double, locale: Locale = .current) {
        self.locale = locale
        self.text = seconds.formatted(.number.locale(locale).grouping(.never).precision(.fractionLength(0...2)))
    }

    /// The typed duration in seconds, or `nil` when it isn't a decimal number within `range`. Takes `.` as well as
    /// the locale's decimal separator.
    var seconds: Double? {
        let number = text.trimmed.replacing(locale.decimalSeparator ?? ".", with: ".")
        // Only digits and one separator, so `Double` can't read an exponent, a sign, `inf` or `nan`.
        guard number.allSatisfy({ ("0"..."9").contains($0) || $0 == "." }),
              number.count(where: { $0 == "." }) <= 1,
              let seconds = Double(number), Self.range.contains(seconds)
        else { return nil }
        return seconds
    }

    var canSave: Bool {
        seconds != nil
    }
}
