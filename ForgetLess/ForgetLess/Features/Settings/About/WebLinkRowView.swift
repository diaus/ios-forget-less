import SwiftUI

/// A list row that opens a web page in Safari.
struct WebLinkRowView: View {
    let title: LocalizedStringResource
    let destination: URL

    var body: some View {
        Link(destination: destination) {
            HStack {
                Text(title)
                    // `Color`, not the hierarchical style: inside a `Link` that resolves to the accent tint.
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .foregroundStyle(Color.secondary)
                    .accessibilityHidden(true)
            }
        }
    }
}
