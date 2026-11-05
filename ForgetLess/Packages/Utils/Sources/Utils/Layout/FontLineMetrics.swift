import CoreGraphics

/// How tall a font's line is at each size, for fitting text to a height.
public struct FontLineMetrics: Sendable {
    /// A line's height per point of font size.
    public let lineHeightPerPoint: CGFloat

    public init(lineHeightPerPoint: CGFloat) {
        self.lineHeightPerPoint = lineHeightPerPoint
    }

    public func lineHeight(ofSize size: CGFloat) -> CGFloat {
        lineHeightPerPoint * size
    }

    /// The largest whole font size whose line fits in `height`.
    public func largestFontSize(fittingLineHeight height: CGFloat) -> CGFloat {
        (height / lineHeightPerPoint).rounded(.down)
    }
}
