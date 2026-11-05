import CoreGraphics

/// How rows of one line of text share a height: the gaps between them shrink before their font does.
public struct TextRowsSizing: Sendable {
    /// The font size, the gap between rows, and how many rows fit, from the start.
    public struct Layout: Equatable, Sendable {
        public let fontSize: CGFloat
        public let gap: CGFloat
        public let rowCount: Int

        public init(fontSize: CGFloat, gap: CGFloat, rowCount: Int) {
            self.fontSize = fontSize
            self.gap = gap
            self.rowCount = rowCount
        }
    }

    public let fullFontSize: CGFloat
    public let fullGap: CGFloat
    public let smallestGap: CGFloat
    public let smallestFontSize: CGFloat
    /// A line's height per point of font size.
    public let lineHeightPerPoint: CGFloat

    public init(
        fullFontSize: CGFloat,
        fullGap: CGFloat,
        smallestGap: CGFloat,
        smallestFontSize: CGFloat,
        lineHeightPerPoint: CGFloat
    ) {
        self.fullFontSize = fullFontSize
        self.fullGap = fullGap
        self.smallestGap = smallestGap
        self.smallestFontSize = smallestFontSize
        self.lineHeightPerPoint = lineHeightPerPoint
    }

    // MARK: - Layout
    /// How `rowCount` rows fit in `height`. Rows that don't fit even at `smallestFontSize` are left out from the end.
    public func layout(rowCount: Int, height: CGFloat) -> Layout {
        var fontSize = fullFontSize
        if lineHeight(ofSize: fontSize) * CGFloat(rowCount) + smallestGap * CGFloat(rowCount - 1) > height {
            fontSize = max(largestFontSize(rowCount: rowCount, gap: smallestGap, height: height), smallestFontSize)
        }
        let rowHeight = lineHeight(ofSize: fontSize)
        let fittingCount = min(rowCount, Int((height + smallestGap) / (rowHeight + smallestGap)))
        let gap = fittingCount > 1
            ? min(fullGap, (height - rowHeight * CGFloat(fittingCount)) / CGFloat(fittingCount - 1))
            : fullGap
        return Layout(fontSize: fontSize, gap: gap, rowCount: fittingCount)
    }

    // MARK: - Helpers
    private func lineHeight(ofSize size: CGFloat) -> CGFloat {
        lineHeightPerPoint * size
    }

    /// The largest whole font size whose `rowCount` lines, with `gap` between them, fit in `height`.
    private func largestFontSize(rowCount: Int, gap: CGFloat, height: CGFloat) -> CGFloat {
        let rowHeight = (height - gap * CGFloat(rowCount - 1)) / CGFloat(rowCount)
        return (rowHeight / lineHeightPerPoint).rounded(.down)
    }
}
