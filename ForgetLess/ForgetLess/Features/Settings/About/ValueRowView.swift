import SwiftUI

/// A list row that shows a title with its value.
struct ValueRowView: View {
    let title: LocalizedStringResource
    let value: String

    var body: some View {
        LabeledContent {
            Text(value)
        } label: {
            Text(title)
        }
        // One element, so VoiceOver reads the title with its value.
        .accessibilityElement(children: .combine)
    }
}
