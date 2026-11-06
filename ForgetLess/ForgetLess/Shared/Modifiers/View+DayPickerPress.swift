import SwiftUI

extension View {
    /// Calls `onLongPress` on a long press, with a haptic once it's recognised, and `onTap` on a shorter tap: the long
    /// press opens the sheet Day picker, where a tap opens a smaller one.
    func dayPickerPress(onTap: @escaping () -> Void, onLongPress: @escaping () -> Void) -> some View {
        modifier(DayPickerPress(onTap: onTap, onLongPress: onLongPress))
    }

    /// The same long press on a button, which keeps its own tap and its look while pressed. The lift that ends a long
    /// press also reaches the button's action.
    func dayPickerLongPress(_ onLongPress: @escaping () -> Void) -> some View {
        modifier(DayPickerPress(onTap: nil, onLongPress: onLongPress))
    }
}

private struct DayPickerPress: ViewModifier {
    /// `nil` on a button, whose own tap stands in.
    let onTap: (() -> Void)?
    let onLongPress: () -> Void

    /// Counts the long presses, for a haptic on each.
    @State private var longPressCount = 0

    /// How long a press takes to open the sheet Day picker.
    private let longPressDuration = 0.35
    /// How far a press can move before it's a swipe or a scroll instead.
    private let longPressDistance: CGFloat = 10

    // MARK: - Body
    func body(content: Content) -> some View {
        Group {
            if let onTap {
                // The tap waits only for the press to fail, which a lift does at once.
                content.gesture(longPress.exclusively(before: TapGesture().onEnded(onTap)))
            } else {
                // Beside the button's own tap rather than before it: a gesture that takes the touch from a button
                // stops it showing as pressed.
                content.simultaneousGesture(longPress)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: longPressCount)
    }

    // MARK: - Gestures
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: longPressDuration, maximumDistance: longPressDistance)
            .onEnded { _ in
                longPressCount += 1
                onLongPress()
            }
    }
}
