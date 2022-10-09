//
// Created by osushi on 2022/09/30.
//

import Foundation
import XCTest

@testable import EffectiveNovelCore

class BracketsPairValidatorTest: XCTestCase {

    func testValidateSuccess() throws {
        let rawText = "aaaa"
        let validator = BracketsPairValidator()

        let result = validator.validate(lineRawText: rawText, lineNo: 0)

        try XCTUnwrap(result.get())
    }

    func testInvalidFrontOnlyBrackets() {
        let rawText = "ab[cdf"
        let expect = ValidationError.invalidBracketsPair(lineNo: 100)
        let validator = BracketsPairValidator()

        switch validator.validate(lineRawText: rawText, lineNo: 100){
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expect, error)
        }
    }

    func testInvalidRearOnlyBrackets() {
        let rawText = "abc]df"
        let expect = ValidationError.invalidBracketsPair(lineNo: 100)
        let validator = BracketsPairValidator()

        switch validator.validate(lineRawText: rawText, lineNo: 100){
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expect, error)
        }
    }

    func testInvalidBracketsPosition() {
        let rawText = "a]bcd[f"
        let expect = ValidationError.invalidBracketsPair(lineNo: 100)
        let validator = BracketsPairValidator()

        switch validator.validate(lineRawText: rawText, lineNo: 100){
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(expect, error)
        }
    }
}
