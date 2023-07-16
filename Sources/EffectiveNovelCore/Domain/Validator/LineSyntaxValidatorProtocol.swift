//
// Created by osushi on 2022/09/28.
//

import Foundation

protocol LineSyntaxValidatorProtocol {
  func validate(lineRawText: String, lineNo: Int) -> Result<Void, ValidationError>
}
