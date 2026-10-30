import Testing
import Utils

struct StringTrimmedTests {
    @Test func trimsWhitespaceAndNewlinesAroundTheText() {
        #expect(" \n Buy milk\t \n".trimmed == "Buy milk")
    }

    @Test(arguments: ["", " \t\n "])
    func trimsBlankTextToEmpty(_ text: String) {
        #expect(text.trimmed.isEmpty)
    }
}
