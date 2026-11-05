import UIKit
import Utils

extension UIFont {
    static var systemLineMetrics: FontLineMetrics {
        // The line height grows in proportion to the size, so one measurement serves every size.
        FontLineMetrics(lineHeightPerPoint: systemFont(ofSize: 100).lineHeight / 100)
    }
}
