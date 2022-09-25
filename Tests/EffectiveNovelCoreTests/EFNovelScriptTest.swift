//
// Created by osushi on 2022/09/25.
//

import Foundation
import XCTest
import Combine
@testable import EffectiveNovelCore

final class EFNovelScriptTest: XCTestCase {

    func testValidateSuccess() {
        let rawText = "ab[cl]d"
        let expect = EFNovelScript(events: [.character(char: "a"), .character(char: "b"), .clear, .character(char: "d")])

        switch EFNovelScript.validate(rawText: rawText) {
        case .success(let script):
            XCTAssertEqual(expect, script)
        case .failure(_):
            XCTFail()
        }
    }

    func testInvalidCommand() {
        let rawText = "ab[a]d"
        let expect = ParseError.commandNotFound(message: "this tag not found: a")

        switch EFNovelScript.validate(rawText: rawText) {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expect, error)
        }
    }

    func testInvalidFrontOnlyBrackets() {
        let rawText = "ab[cdf"
        let expect = ParseError.invalidBracketsPair(message: "brackets pair broken")

        switch EFNovelScript.validate(rawText: rawText) {
        case .success(let script):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expect, error)
        }
    }

    func testInvalidRearOnlyBrackets() {
        let rawText = "abc]df"
        let expect = ParseError.invalidBracketsPair(message: "brackets pair broken")

        switch EFNovelScript.validate(rawText: rawText) {
        case .success(let script):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expect, error)
        }
    }
}
