//
// Created by osushi on 2022/09/28.
//

import Foundation

protocol AllStringSyntaxValidator {
    func validate(allStringRawText: String) -> Result<Void, ValidationError>
}

protocol LineSyntaxValidator {
    func validate(lineRawText: String, lineNo: Int) -> Result<Void, ValidationError>
}
