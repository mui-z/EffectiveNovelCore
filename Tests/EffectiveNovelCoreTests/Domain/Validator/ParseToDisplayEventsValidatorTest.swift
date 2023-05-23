//
// Created by osushi on 2022/09/30.
//

import Foundation
import XCTest
@testable import EffectiveNovelCore

final class ParseToDisplayEventsValidatorTest: XCTestCase {
  
  func testParseValid() throws {
    let validator = ParseToDisplayEventsValidator()
    
    let result = validator.validate(lineRawText: "aa[cl]aa", lineNo: 0)
    
    try XCTUnwrap(result.get())
  }
  
  func testParseInvalid() {
    let validator = ParseToDisplayEventsValidator()
    
    let expect = ValidationError.unknownTag(lineNo: 0, tagName: "invalid")
    
    let result = validator.validate(lineRawText: "aa[invalid]aa", lineNo: 0)
    
    switch result {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertEqual(expect, error)
    }
  }
}
