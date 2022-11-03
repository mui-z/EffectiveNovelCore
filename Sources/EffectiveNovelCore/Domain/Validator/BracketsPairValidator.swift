//
// Created by osushi on 2022/09/30.
//

import Foundation

struct BracketsPairValidator: LineSyntaxValidator {
    func validate(lineRawText: String, lineNo: Int) -> Result<(), ValidationError> {

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
