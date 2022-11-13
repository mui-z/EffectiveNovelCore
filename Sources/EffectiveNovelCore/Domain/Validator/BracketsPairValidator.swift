//
// Created by osushi on 2022/09/30.
//

import Foundation

protocol BracketsPairValidatorProtocol: LineSyntaxValidatorProtocol {}

struct BracketsPairValidator: BracketsPairValidatorProtocol {
    func validate(lineRawText: String, lineNo: Int) -> Result<Void, ValidationError> {

        var frontBracketsCount = 0
        var rearBracketsCount = 0

        for char in lineRawText {
            if char == "[" {
                frontBracketsCount += 1
            } else if char == "]" {
                rearBracketsCount += 1
            }

            if frontBracketsCount < rearBracketsCount {
                return .failure(.invalidBracketsPair(lineNo: lineNo))
            }
        }

        if frontBracketsCount != rearBracketsCount {
            return .failure(.invalidBracketsPair(lineNo: lineNo))
        }

        return .success(())
    }
}
