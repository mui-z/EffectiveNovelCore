import XCTest
import Factory
@testable import EffectiveNovelCore

final class ScriptParserTests: XCTestCase {
  
  func testParseText() {
    @Injected(\.scriptParser)
    var parser: ScriptParserProtocol
    
    XCTAssertEqual(try! parser.parse(rawString: "ab[e]"), [.character(char: "a"), .character(char: "b"), .end])
    
    let multiLineText = """
                            aa
                            b
                            [e]
                            """
    XCTAssertEqual(try! parser.parse(rawString: multiLineText), [.character(char: "a"), .character(char: "a"), .character(char: "b"), .end])
  }
  
  func testParseAllCommands() {
    @Injected(\.scriptParser)
    var parser: ScriptParserProtocol
    
    XCTAssertEqual(try! parser.parse(rawString: "[n][e]"), [.newline, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[tw][e]"), [.tapWait, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[twn][e]"), [.tapWaitAndNewline, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[cl][e]"), [.clear, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[setDefaultDelay speed=1000][e]"), [.setDefaultDelay(speed: 1000), .end])
    XCTAssertEqual(try! parser.parse(rawString: "[delay speed=1000][e]"), [.delay(speed: 1000), .end])
    XCTAssertEqual(try! parser.parse(rawString: "[resetDelay][e]"), [.resetDelay, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[sleep duration=200]"), [.sleep(duration: 200)])
    XCTAssertEqual(try! parser.parse(rawString: "[e]"), [.end])
  }
  
  func testParseEvents() {
    @Injected(\.scriptParser)
    var parser: ScriptParserProtocol
    
    XCTAssertEqual(try! parser.parse(rawString: "[cl][e]"), [.clear, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[cl][n][e]"), [.clear, .newline, .end])
    XCTAssertEqual(try! parser.parse(rawString: "s[tw][e]"), [.character(char: "s"), .tapWait, .end])
    XCTAssertEqual(try! parser.parse(rawString: "[cl]e[e]"), [.clear, .character(char: "e"), .end])
    XCTAssertEqual(try! parser.parse(rawString: "s[cl]e[e]"), [.character(char: "s"), .clear, .character(char: "e"), .end])
  }
  
  func testContainValueEvent() {
    @Injected(\.scriptParser)
    var parser: ScriptParserProtocol
    
    XCTAssertEqual(try! parser.parse(rawString: "[delay speed=1000][e]"), [.delay(speed: 1000), .end])
    XCTAssertEqual(try! parser.parse(rawString: "[delay speed=1000][delay speed=2000][e]"), [.delay(speed: 1000), .delay(speed: 2000), .end])
    XCTAssertEqual(try! parser.parse(rawString: "t[delay speed=1000][e]"), [.character(char: "t"), .delay(speed: 1000), .end])
    XCTAssertEqual(try! parser.parse(rawString: "[delay speed=1000]t[e]"), [.delay(speed: 1000), .character(char: "t"), .end])
    XCTAssertEqual(try! parser.parse(rawString: "s[delay speed=1000]e[e]"), [.character(char: "s"), .delay(speed: 1000), .character(char: "e"), .end])
  }
}
