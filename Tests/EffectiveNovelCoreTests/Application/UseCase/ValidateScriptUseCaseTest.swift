//
// Created by osushi on 2022/09/30.
//

import Foundation
import XCTest

@testable import EffectiveNovelCore

final class ValidateScriptUseCaseTest: XCTestCase {
  
  func testValidateFail() {
    let useCase: ValidateScriptUseCaseProtocol = ValidateScriptUseCase()
    let expect: [ValidationError] = [
      .unknownTag(lineNo: 2, tagName: "invalid_tag"),
      .invalidBracketsPair(lineNo: 3),
      .unknownTag(lineNo: 3, tagName: "aa"),
      .invalidBracketsPair(lineNo: 4),
      .unknownTag(lineNo: 4, tagName: "23"),
      .notFoundMustIncludeTag(notFoundTags: [.end])
    ]
    
    let result = useCase.validate(rawAllString: """
                                                    first line
                                                    123[invalid_tag]
                                                    aa]bb[cc
                                                    1[23]]456[[234
                                                    third line
                                                    """)
    switch result {
      case .valid:
        XCTFail()
      case .invalid(let errors):
        XCTAssertEqual(errors, expect)
    }
  }
  
  func testValidateSuccess() {
    let useCase: ValidateScriptUseCaseProtocol = ValidateScriptUseCase()
    let expect: [DisplayEvent] = [
      .character(char: "v"),
      .character(char: "a"),
      .character(char: "l"),
      .end
    ]
    let result = useCase.validate(rawAllString: """
                                                    val[e]
                                                    """)
    
    switch result {
      case .valid(let script):
        XCTAssertEqual(expect, script.displayEvents)
      case .invalid(let error):
        print(error)
        XCTFail()
    }
  }
}
