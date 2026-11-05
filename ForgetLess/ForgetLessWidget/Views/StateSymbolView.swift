import Domain
import SwiftUI
import WidgetKit

/// Stands in for the list when there's no Task to list, or the Tasks couldn't be read.
struct StateSymbolView: View {
    let badgeSystemName: String

    @Environment(\.widgetFamily) private var family

    /// The composed symbol's height, as a share of the Lock Screen widget's.
    private static let lockScreenHeightShare: CGFloat = 2 / 3
    /// The composed symbol's height, as a share of the Home Screen widget's.
    private static let homeScreenHeightShare: CGFloat = 0.4
    /// The badge's size, as a share of the checklist's.
    private static let badgeShare: CGFloat = 1
    /// The square cut out of the checklist around the badge, as a share of the badge's size.
    private static let gapShare: CGFloat = 1.2

    var body: some View {
        GeometryReader { proxy in
            let heightShare = family.isOnLockScreen ? Self.lockScreenHeightShare : Self.homeScreenHeightShare
            // The badge is centred on the checklist's corner, so half of it stands above.
            let checklistSize = proxy.size.height * heightShare / (1 + Self.badgeShare / 2)
            let badgeSize = checklistSize * Self.badgeShare
            Image(systemName: "checklist.unchecked")
                .resizable()
                .scaledToFit()
                .frame(width: checklistSize, height: checklistSize)
                .overlay(alignment: .topTrailing) {
                    ZStack {
                        // The checklist is cut away around and under the badge, so the two don't run together.
                        Rectangle()
                            .frame(width: badgeSize * Self.gapShare, height: badgeSize * Self.gapShare)
                            .blendMode(.destinationOut)
                        Image(systemName: badgeSystemName)
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.bold)
                            .frame(width: badgeSize, height: badgeSize)
                    }
                    .frame(width: badgeSize, height: badgeSize)
                    .offset(x: badgeSize / 2, y: -badgeSize / 2)
                }
                .compositingGroup()
                // Centres the symbol with its badge, not the checklist alone.
                .padding(.top, badgeSize / 2)
                .padding(.trailing, badgeSize / 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Empty", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .empty)
}

#Preview("Unreadable", as: .accessoryRectangular) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .unreadable)
}

#Preview("Home Screen, empty", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .empty)
}

#Preview("Home Screen, unreadable", as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    UpcomingWidgetEntry(date: .now, content: .unreadable)
}
