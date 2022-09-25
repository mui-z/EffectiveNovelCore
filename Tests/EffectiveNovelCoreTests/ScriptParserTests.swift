import XCTest
@testable import EffectiveNovelCore

final class ScriptParserTests: XCTestCase {

    func testParseText() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "ab[e]"), [.character(char: "a"), .character(char: "b"), .end])

        let multiLineText = """
                            aa
                            b
                            [e]
                            """
        XCTAssertEqual(try! parser.parse(rawAllString: multiLineText), [.character(char: "a"), .character(char: "a"), .character(char: "b"), .end])
    }

    func testParseAllCommands() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "[n][e]"), [.newline, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[tw][e]"), [.tapWait, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[twn][e]"), [.tapWaitAndNewline, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[cl][e]"), [.clear, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000][e]"), [.delay(speed: 1000), .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[resetdelay][e]"), [.resetDelay, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[e]"), [.end])
    }

    func testParseEvents() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "[cl][e]"), [.clear, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[cl][n][e]"), [.clear, .newline, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "s[tw][e]"), [.character(char: "s"), .tapWait, .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[cl]e[e]"), [.clear, .character(char: "e"), .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "s[cl]e[e]"), [.character(char: "s"), .clear, .character(char: "e"), .end])
    }

    func testContainValueEvent() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000][e]"), [.delay(speed: 1000), .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000][delay speed=2000][e]"), [.delay(speed: 1000), .delay(speed: 2000), .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "t[delay speed=1000][e]"), [.character(char: "t"), .delay(speed: 1000), .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000]t[e]"), [.delay(speed: 1000), .character(char: "t"), .end])
        XCTAssertEqual(try! parser.parse(rawAllString: "s[delay speed=1000]e[e]"), [.character(char: "s"), .delay(speed: 1000), .character(char: "e"), .end])
    }
}