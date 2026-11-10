import AppIntents
import Foundation

/// A choice of the widget's Grace Period, which only the sizes with controls offer (ADR 0005).
nonisolated struct WidgetGracePeriod: AppEntity {
    // App Intents metadata takes only string literals, not catalog symbols, so the title is its catalog key, which
    // the system looks up in the widget's copy of the String Catalog.
    // swiftlint:disable:next catalog_key_literal
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widget.gracePeriod"
    static let defaultQuery = WidgetGracePeriodQuery()
    static let choices = [0, 3, 5, 10, 20].map(WidgetGracePeriod.init(id:))
    static let standard = WidgetGracePeriod(id: 3)

    /// The Grace Period in whole seconds.
    let id: Int

    var duration: TimeInterval {
        TimeInterval(id)
    }

    var displayRepresentation: DisplayRepresentation {
        guard id > 0 else { return DisplayRepresentation(title: .widgetGracePeriodOff) }
        // The formatter localizes the duration, so it needs no catalog key: a title the catalog lacks shows as written.
        let title = Duration.seconds(id).formatted(.units(allowed: [.seconds], width: .abbreviated))
        return DisplayRepresentation(title: LocalizedStringResource(stringLiteral: title))
    }
}

/// The Grace Periods a widget's settings offer.
nonisolated struct WidgetGracePeriodQuery: EnumerableEntityQuery {
    func allEntities() async -> [WidgetGracePeriod] {
        WidgetGracePeriod.choices
    }

    func entities(for identifiers: [Int]) async -> [WidgetGracePeriod] {
        WidgetGracePeriod.choices.filter { identifiers.contains($0.id) }
    }

    func defaultResult() async -> WidgetGracePeriod? {
        .standard
    }
}
