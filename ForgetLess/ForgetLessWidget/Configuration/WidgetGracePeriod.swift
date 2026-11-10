import AppIntents
import Foundation

// App Intents metadata takes only string literals, not catalog symbols, so the titles are their catalog keys, which
// the system looks up in the widget's copy of the String Catalog.
// swiftlint:disable catalog_key_literal

/// A choice of the widget's Grace Period, which only the sizes with controls offer (ADR 0005).
nonisolated enum WidgetGracePeriod: String, AppEnum {
    case off
    case threeSeconds
    case fiveSeconds
    case tenSeconds
    case twentySeconds

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widget.gracePeriod"

    static let caseDisplayRepresentations: [WidgetGracePeriod: DisplayRepresentation] = [
        .off: "widget.gracePeriod.off",
        .threeSeconds: "widget.gracePeriod.threeSeconds",
        .fiveSeconds: "widget.gracePeriod.fiveSeconds",
        .tenSeconds: "widget.gracePeriod.tenSeconds",
        .twentySeconds: "widget.gracePeriod.twentySeconds",
    ]

    var duration: TimeInterval {
        switch self {
        case .off: 0
        case .threeSeconds: 3
        case .fiveSeconds: 5
        case .tenSeconds: 10
        case .twentySeconds: 20
        }
    }
}

// swiftlint:enable catalog_key_literal
