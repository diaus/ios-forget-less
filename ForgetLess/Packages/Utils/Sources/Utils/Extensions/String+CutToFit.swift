import CoreGraphics

public extension String {
    /// The receiver whole when it fits in `width`, or else its longest start that fits followed by `ending`. With room
    /// for no character, only `ending` is left.
    /// - Parameter measure: The width `text` takes, in the unit of `width`.
    func cut(toFit width: CGFloat, ending: String, measuredBy measure: (_ text: String) -> CGFloat) -> String {
        guard measure(self) > width else { return self }
        let characters = Array(self)
        // Binary search for the longest start that fits with the ending.
        var fitting = 0
        var tooLong = characters.count
        while tooLong - fitting > 1 {
            let count = (fitting + tooLong) / 2
            if measure(String(characters[..<count]) + ending) <= width {
                fitting = count
            } else {
                tooLong = count
            }
        }
        let start = String(characters[..<fitting])
        // A word cut before its space would read as a whole word, so the space goes too.
        return String(start.reversed().drop { $0.isWhitespace }.reversed()) + ending
    }
}
