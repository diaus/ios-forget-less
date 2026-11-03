import Foundation
import Testing
@testable import ForgetLess

@MainActor
struct DayChipCalendarLayoutTests {
    // MARK: - Tests
    @Test(arguments: [true, false])
    func withRoomItShowsFullRowsAndTheButtons(isKeyboardUp: Bool) {
        // 32 + 60 + 5 × 50 + 40 = 382 is the full calendar's height.
        let layout = layout(availableHeight: 400, isKeyboardUp: isKeyboardUp)

        #expect(layout == DayChipCalendarLayout(rowHeight: 50, showsButtons: true, hidesKeyboard: false))
    }

    @Test(arguments: [true, false])
    func shortOfRoomForTheButtonsItHidesThem(isKeyboardUp: Bool) {
        // Over 32 + 60 + 5 × 50 = 342, under 382.
        let layout = layout(availableHeight: 350, isKeyboardUp: isKeyboardUp)

        #expect(layout == DayChipCalendarLayout(rowHeight: 50, showsButtons: false, hidesKeyboard: false))
    }

    @Test(arguments: [true, false], [(292, 40), (272, 36)])
    func shortOfRoomForFullRowsItShrinksThemDownTo36(isKeyboardUp: Bool, heights: (available: CGFloat, row: CGFloat)) {
        let layout = layout(availableHeight: heights.available, isKeyboardUp: isKeyboardUp)

        #expect(layout == DayChipCalendarLayout(rowHeight: heights.row, showsButtons: false, hidesKeyboard: false))
    }

    @Test func shortOfRoomFor36RowsItHidesTheKeyboard() {
        // Under 32 + 60 + 5 × 36 = 272; the rows fill what there is while the keyboard goes down.
        let layout = layout(availableHeight: 242, isKeyboardUp: true)

        #expect(layout == DayChipCalendarLayout(rowHeight: 30, showsButtons: false, hidesKeyboard: true))
    }

    @Test(arguments: [247, 120])
    func withTheKeyboardDownAndNoRoomFor36RowsTheRowsFillTheHeight(availableHeight: CGFloat) {
        let layout = layout(availableHeight: availableHeight, isKeyboardUp: false)

        #expect(!layout.showsButtons)
        #expect(!layout.hidesKeyboard)
        #expect(32 + 60 + 5 * layout.rowHeight == availableHeight)
    }

    @Test func withNoRoomForAnyRowTheRowsHaveNoHeight() {
        let layout = layout(availableHeight: 80, isKeyboardUp: false)

        #expect(layout.rowHeight == 0)
    }

    // MARK: - Helpers
    /// A calendar with a 60 pt header, 40 pt of buttons and 32 pt of padding.
    private func layout(availableHeight: CGFloat, isKeyboardUp: Bool) -> DayChipCalendarLayout {
        DayChipCalendarLayout(
            availableHeight: availableHeight,
            headerHeight: 60,
            buttonsHeight: 40,
            padding: 32,
            isKeyboardUp: isKeyboardUp
        )
    }
}
