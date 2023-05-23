//
// Created by osushi on 2022/09/30.
//

import Foundation
import XCTest
@testable import EffectiveNovelCore

final class MustContainsIncludeTagsValidatorTest: XCTestCase {
  
  func testMustContainsTagSuccess() throws {
    let validator = MustContainsIncludeTagsValidator()
    let result = validator.validate(allStringRawText: "sample[e]")
    
    try XCTUnwrap(result.get())
  }
  
  func testMustContainsTagFail() throws {
    let validator = MustContainsIncludeTagsValidator()
    let result = validator.validate(allStringRawText: "sample")
    
    switch result {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertEqual(error, ValidationError.notFoundMustIncludeTag(notFoundTags: [.end]))
    }
  }
}
