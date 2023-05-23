//
// Created by osushi on 2022/09/28.
//

import Foundation

protocol AllStringSyntaxValidatorProtocol {
  func validate(allStringRawText: String) -> Result<Void, ValidationError>
}

protocol LineSyntaxValidatorProtocol {
  func validate(lineRawText: String, lineNo: Int) -> Result<Void, ValidationError>
}
