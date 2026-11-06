import CoreGraphics

/// How the floating Day picker fits the space it has.
struct FloatingDayPickerLayout: Equatable {
    let rowHeight: CGFloat
    let showsButtons: Bool
    /// Whether the keyboard must go down to make room.
    let hidesKeyboard: Bool
}

extension FloatingDayPickerLayout {
    /// The widest the picker grows, so its Days never spread out on a wide screen.
    static let maxWidth: CGFloat = 400
    /// Every month as many weeks, so paging never changes the picker's height.
    static let weekCount = 5
    /// The shortest a row shrinks before the keyboard goes down to make room.
    private static let minimumRowHeight: CGFloat = 36

    /// Fits the picker in `availableHeight`, around its header (the month's name and the weekday row), its buttons
    /// with the space under them, and the rest of its `padding`.
    init(
        availableHeight: CGFloat,
        headerHeight: CGFloat,
        buttonsHeight: CGFloat,
        padding: CGFloat,
        isKeyboardUp: Bool
    ) {
        let rowsHeight = availableHeight - padding - headerHeight
        let showsButtons = rowsHeight - buttonsHeight >= Self.fullRowsHeight
        let rowHeight = min(max(rowsHeight, 0) / CGFloat(Self.weekCount), PickerDayView.fullRowHeight)
        let hidesKeyboard = isKeyboardUp && rowHeight < Self.minimumRowHeight
        self.init(rowHeight: rowHeight, showsButtons: showsButtons, hidesKeyboard: hidesKeyboard)
    }

    /// The height the picker takes when nothing has to make room: full rows and the buttons.
    static func fullHeight(headerHeight: CGFloat, buttonsHeight: CGFloat, padding: CGFloat) -> CGFloat {
        padding + headerHeight + fullRowsHeight + buttonsHeight
    }

    private static var fullRowsHeight: CGFloat {
        PickerDayView.fullRowHeight * CGFloat(weekCount)
    }
}
