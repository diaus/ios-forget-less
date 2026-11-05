import CoreGraphics
import Testing
import Utils

struct FontLineMetricsTests {
    private let metrics = FontLineMetrics(lineHeightPerPoint: 2)

    @Test func aLineGrowsWithItsFontSize() {
        #expect(metrics.lineHeight(ofSize: 17) == 34)
    }

    @Test func theLargestFontSizeForALineHeightIsWholeAndFits() {
        #expect(metrics.largestFontSize(fittingLineHeight: 28) == 14)
        #expect(metrics.largestFontSize(fittingLineHeight: 29) == 14)
    }
}
