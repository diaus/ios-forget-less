import UIKit

extension UIFont {
    static func systemLineHeight(ofSize size: CGFloat) -> CGFloat {
        // The line height grows in proportion to the size, so one measurement serves every size.
        systemFont(ofSize: 100).lineHeight / 100 * size
    }

    /// The largest whole system font size whose line fits in `height`.
    static func largestSystemFontSize(fittingLineHeight height: CGFloat) -> CGFloat {
        (height / systemLineHeight(ofSize: 1)).rounded(.down)
    }
}
