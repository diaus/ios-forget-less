import CoreGraphics
import Testing
import Utils

struct TextRowsSizingTests {
    // A line twice as tall as its font size, so a size and its line height can't be mistaken for each other.
    private let sizing = TextRowsSizing(
        fullFontSize: 17,
        fullGap: 5,
        smallestGap: 1,
        smallestFontSize: 12,
        lineHeightPerPoint: 2
    )

    // MARK: - Tests
    @Test func rowsWithRoomToSpareTakeTheFullFontAndGap() {
        let layout = sizing.layout(rowCount: 2, height: 100)

        #expect(layout == TextRowsSizing.Layout(fontSize: 17, gap: 5, rowCount: 2))
    }

    @Test func theGapsShrinkBeforeTheFontDoes() {
        let layout = sizing.layout(rowCount: 3, height: 106)

        #expect(layout == TextRowsSizing.Layout(fontSize: 17, gap: 2, rowCount: 3))
    }

    @Test func pastTheSmallestGapTheFontShrinksToTheLargestWholeSizeThatFits() {
        let exact = sizing.layout(rowCount: 3, height: 86)
        let between = sizing.layout(rowCount: 3, height: 89)

        #expect(exact == TextRowsSizing.Layout(fontSize: 14, gap: 1, rowCount: 3))
        #expect(between == TextRowsSizing.Layout(fontSize: 14, gap: 2.5, rowCount: 3))
    }

    @Test func atTheSmallestFontRowsThatDoNotFitAreLeftOutFromTheEnd() {
        let layout = sizing.layout(rowCount: 10, height: 99)

        #expect(layout == TextRowsSizing.Layout(fontSize: 12, gap: 1, rowCount: 4))
    }
}
