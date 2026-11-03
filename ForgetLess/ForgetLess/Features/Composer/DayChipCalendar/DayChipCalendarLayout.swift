import CoreGraphics

/// How the Day chip calendar fits the height it has.
struct DayChipCalendarLayout: Equatable {
    let rowHeight: CGFloat
    let showsButtons: Bool
    /// Whether the keyboard must go down to make room.
    let hidesKeyboard: Bool
}

extension DayChipCalendarLayout {
    /// Every month as many weeks, so paging never changes the calendar's height.
    static let weekCount = 5
    /// The shortest a row shrinks before the keyboard goes down to make room.
    private static let minimumRowHeight: CGFloat = 36

    /// Fits the calendar in `availableHeight`, around its header (the month's name and the weekday row), its buttons
    /// with the space under them, and the rest of its `padding`.
    init(
        availableHeight: CGFloat,
        headerHeight: CGFloat,
        buttonsHeight: CGFloat,
        padding: CGFloat,
        isKeyboardUp: Bool
    ) {
        let rowsHeight = availableHeight - padding - headerHeight
        let fullRowsHeight = DayPickerDayView.fullRowHeight * CGFloat(Self.weekCount)
        let showsButtons = rowsHeight - buttonsHeight >= fullRowsHeight
        let rowHeight = min(max(rowsHeight, 0) / CGFloat(Self.weekCount), DayPickerDayView.fullRowHeight)
        let hidesKeyboard = isKeyboardUp && rowHeight < Self.minimumRowHeight
        self.init(rowHeight: rowHeight, showsButtons: showsButtons, hidesKeyboard: hidesKeyboard)
    }
}
