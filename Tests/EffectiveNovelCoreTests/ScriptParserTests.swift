import XCTest
@testable import EffectiveNovelCore

final class ScriptParserTests: XCTestCase {

    func testParseText() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "ab"), [.character(char: "a"), .character(char: "b")])

        let multiLineText = """
                            aa
                            b
                            """
        XCTAssertEqual(try! parser.parse(rawAllString: multiLineText), [.character(char: "a"), .character(char: "a"), .character(char: "b")])
    }

    func testParseAllCommands() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "[n]"), [.newline])
        XCTAssertEqual(try! parser.parse(rawAllString: "[tw]"), [.tapWait])
        XCTAssertEqual(try! parser.parse(rawAllString: "[twn]"), [.tapWaitAndNewline])
        XCTAssertEqual(try! parser.parse(rawAllString: "[cl]"), [.clear])
        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000]"), [.delay(speed: 1000)])
        XCTAssertEqual(try! parser.parse(rawAllString: "[resetdelay]"), [.resetDelay])
        XCTAssertEqual(try! parser.parse(rawAllString: "[e]"), [.end])
    }

    func testParseEvents() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "[cl]"), [.clear])
        XCTAssertEqual(try! parser.parse(rawAllString: "[cl][n]"), [.clear, .newline])
        XCTAssertEqual(try! parser.parse(rawAllString: "s[tw]"), [.character(char: "s"), .tapWait])
        XCTAssertEqual(try! parser.parse(rawAllString: "[cl]e"), [.clear, .character(char: "e")])
        XCTAssertEqual(try! parser.parse(rawAllString: "s[cl]e"), [.character(char: "s"), .clear, .character(char: "e")])
    }

    func testContainValueEvent() {
        let parser = ScriptParser()

        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000]"), [.delay(speed: 1000)])
        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000][delay speed=2000]"), [.delay(speed: 1000), .delay(speed: 2000)])
        XCTAssertEqual(try! parser.parse(rawAllString: "t[delay speed=1000]"), [.character(char: "t"), .delay(speed: 1000)])
        XCTAssertEqual(try! parser.parse(rawAllString: "[delay speed=1000]t"), [.delay(speed: 1000), .character(char: "t")])
        XCTAssertEqual(try! parser.parse(rawAllString: "s[delay speed=1000]e"), [.character(char: "s"), .delay(speed: 1000), .character(char: "e")])
    }
}