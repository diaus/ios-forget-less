import SwiftUI

extension View {
    /// Shows `message` in an alert while it's non-nil, and clears it when the alert is dismissed.
    func errorAlert(message: Binding<String?>) -> some View {
        alert(
            Text(.errorTitle),
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            presenting: message.wrappedValue,
            actions: { _ in },
            message: { Text($0) }
        )
    }
}
