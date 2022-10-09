//
// Created by osushi on 2022/09/28.
//

import Foundation

internal protocol AllStringSyntaxValidator {
    func validate(allStringRawText: String) -> Result<Void, ValidationError>
}

internal protocol LineSyntaxValidator {
    func validate(lineRawText: String, lineNo: Int) -> Result<Void, ValidationError>
}
