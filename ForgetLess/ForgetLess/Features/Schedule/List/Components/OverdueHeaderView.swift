import SwiftUI

/// The Overdue section's header in the Schedule.
struct OverdueHeaderView: View {
    var body: some View {
        // No "+": a Task can't be planned in the past.
        HStack {
            Text(.scheduleOverdue)
            Spacer()
        }
        .font(.subheadline.bold())
        // A colour, not the `.primary` style, which resolves against the header's grey.
        .foregroundStyle(Color.primary)
        .textCase(nil)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    OverdueHeaderView()
}
