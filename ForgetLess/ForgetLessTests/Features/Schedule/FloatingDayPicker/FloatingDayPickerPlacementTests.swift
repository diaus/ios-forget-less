import CoreGraphics
import Testing
@testable import ForgetLess

@MainActor
struct FloatingDayPickerPlacementTests {
    /// The space the list shows: 100 pt down to 900 pt, 400 pt wide.
    private let space = CGRect(x: 0, y: 100, width: 400, height: 800)
    /// The full picker's height.
    private let fullHeight: CGFloat = 380

    // MARK: - Tests
    @Test func withRoomUnderTheRowItOpensBelowIt() {
        // 900 − 8 − (300 + 8) = 584 below.
        let placement = placement(rowY: 250)

        #expect(placement.opensBelow)
        #expect(placement.frame.minY == 308)
        #expect(placement.frame.height == 584)
    }

    @Test func withRoomOnlyAboveTheRowItOpensAboveIt() {
        // 900 − 8 − (800 + 8) = 84 below; (750 − 8) − (100 + 8) = 634 above.
        let placement = placement(rowY: 750)

        #expect(!placement.opensBelow)
        #expect(placement.frame.maxY == 742)
        #expect(placement.frame.height == 634)
    }

    /// Below a row at `rowY` there are 834 − `rowY` pt, and above it `rowY` − 116 pt.
    @Test(arguments: [(420, true, 414), (600, false, 484), (475, true, 359)])
    func withRoomOnNeitherSideItOpensOnTheSideWithMoreOrBelowOnATie(
        rowY: CGFloat,
        opensBelow: Bool,
        height: CGFloat
    ) {
        let placement = placement(rowY: rowY, fullHeight: 500)

        #expect(placement.opensBelow == opensBelow)
        #expect(placement.frame.height == height)
    }

    @Test func aRowUnderTheTopOfTheSpaceOpensBelow() {
        let placement = placement(rowY: 80)

        #expect(placement.opensBelow)
    }

    @Test(arguments: [(300, 100), (20, 20), (580, 180)])
    func onAWideRowItsWidthIsCappedAndCentredOnTheTapWithinTheRow(tapX: CGFloat, minX: CGFloat) {
        let row = CGRect(x: 20, y: 250, width: 560, height: 50)

        let placement = FloatingDayPickerPlacement(
            row: row,
            tap: CGPoint(x: tapX, y: 275),
            space: CGRect(x: 0, y: 100, width: 600, height: 800),
            fullHeight: fullHeight
        )

        #expect(placement.frame.width == 400)
        #expect(placement.frame.minX == minX)
    }

    @Test func onANarrowRowItTakesTheRowsWidth() {
        let placement = placement(rowY: 250)

        #expect(placement.frame.minX == 16)
        #expect(placement.frame.width == 368)
    }

    // MARK: - Helpers
    /// A 50 pt row at `rowY`, with the list's 16 pt margins, tapped in its middle.
    private func placement(rowY: CGFloat, fullHeight: CGFloat? = nil) -> FloatingDayPickerPlacement {
        FloatingDayPickerPlacement(
            row: CGRect(x: 16, y: rowY, width: 368, height: 50),
            tap: CGPoint(x: 200, y: rowY + 25),
            space: space,
            fullHeight: fullHeight ?? self.fullHeight
        )
    }
}
