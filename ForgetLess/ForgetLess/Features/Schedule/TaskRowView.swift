import Domain
import SwiftUI

/// A Task in the list: its circle and its name.
struct TaskRowView: View {
    let task: TodoTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(task.name)
        }
    }
}
