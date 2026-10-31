import AppIntents

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// What ends a name the two-column layout cuts to fit its column.
nonisolated enum CutEnding: String, AppEnum {
    case verticalEllipsis
    case ellipsis
    /// The name is cut with nothing after it.
    case empty

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widget.cutEnding"

    // A glyph isn't translated, so it has no catalog key: a title the catalog lacks shows as written.
    static let caseDisplayRepresentations: [CutEnding: DisplayRepresentation] = [
        .verticalEllipsis: "⋮",
        .ellipsis: "…",
        .empty: "widget.cutEnding.empty",
    ]

    var text: String {
        switch self {
        case .verticalEllipsis: "⋮"
        case .ellipsis: "…"
        case .empty: ""
        }
    }
}

// swiftlint:enable catalog_key_literal
