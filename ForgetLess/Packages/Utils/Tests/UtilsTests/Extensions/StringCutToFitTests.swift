import CoreGraphics
import Testing
import Utils

struct StringCutToFitTests {
    // MARK: - Tests
    @Test func textThatFitsIsKeptWholeWithNoEnding() {
        #expect("Buy milk".cut(toFit: 8, ending: "…", measuredBy: width) == "Buy milk")
    }

    @Test func textTooWideKeepsItsLongestStartThatFitsWithTheEnding() {
        #expect("Buy oat milk".cut(toFit: 8, ending: "…", measuredBy: width) == "Buy oat…")
        #expect("Buy oat milk".cut(toFit: 6, ending: "", measuredBy: width) == "Buy oa")
    }

    @Test func aCutRightAfterASpaceDropsTheSpace() {
        #expect("Buy oat milk".cut(toFit: 5, ending: "…", measuredBy: width) == "Buy…")
    }

    @Test func withRoomForNoCharacterOnlyTheEndingIsLeft() {
        #expect("Buy milk".cut(toFit: 0, ending: "…", measuredBy: width) == "…")
    }

    // MARK: - Helpers
    /// Each character one point wide.
    private func width(of text: String) -> CGFloat {
        CGFloat(text.count)
    }
}
