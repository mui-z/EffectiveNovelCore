import XCTest
@testable import EffectiveNovelCore

final class ScriptParserTests: XCTestCase {

    func testParseText() {
        let parser = ScriptParser()

        XCTAssertEqual(parser.parse(rawAllString: "ab"), [.character(char: "a"), .character(char: "b")])

        let multiLineText = """
                            aa
                            b
                            """
        XCTAssertEqual(parser.parse(rawAllString: multiLineText), [.character(char: "a"), .character(char: "a"), .character(char: "b")])
    }

    func testParseAllCommands() {
        let parser = ScriptParser()

        XCTAssertEqual(parser.parse(rawAllString: "[n]"), [.newline])
        XCTAssertEqual(parser.parse(rawAllString: "[tw]"), [.tapWait])
        XCTAssertEqual(parser.parse(rawAllString: "[twn]"), [.tapWaitAndNewline])
        XCTAssertEqual(parser.parse(rawAllString: "[cl]"), [.clear])
        XCTAssertEqual(parser.parse(rawAllString: "[delay speed=1000]"), [.delay(speed: 1000)])
        XCTAssertEqual(parser.parse(rawAllString: "[resetdelay]"), [.resetDelay])
        XCTAssertEqual(parser.parse(rawAllString: "[e]"), [.end])
    }

    func testParseEvents() {
        let parser = ScriptParser()

        XCTAssertEqual(parser.parse(rawAllString: "[cl]"), [.clear])
        XCTAssertEqual(parser.parse(rawAllString: "[cl][n]"), [.clear, .newline])
        XCTAssertEqual(parser.parse(rawAllString: "s[tw]"), [.character(char: "s"), .tapWait])
        XCTAssertEqual(parser.parse(rawAllString: "[cl]e"), [.clear, .character(char: "e")])
        XCTAssertEqual(parser.parse(rawAllString: "s[cl]e"), [.character(char: "s"), .clear, .character(char: "e")])
    }

    func testContainValueEvent() {
        let parser = ScriptParser()

        XCTAssertEqual(parser.parse(rawAllString: "[delay speed=1000]"), [.delay(speed: 1000)])
        XCTAssertEqual(parser.parse(rawAllString: "[delay speed=1000][delay speed=2000]"), [.delay(speed: 1000), .delay(speed: 2000)])
        XCTAssertEqual(parser.parse(rawAllString: "t[delay speed=1000]"), [.character(char: "t"), .delay(speed: 1000)])
        XCTAssertEqual(parser.parse(rawAllString: "[delay speed=1000]t"), [.delay(speed: 1000), .character(char: "t")])
        XCTAssertEqual(parser.parse(rawAllString: "s[delay speed=1000]e"), [.character(char: "s"), .delay(speed: 1000), .character(char: "e")])
    }
}