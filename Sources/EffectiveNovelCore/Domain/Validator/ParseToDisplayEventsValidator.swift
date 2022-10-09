//
// Created by osushi on 2022/09/30.
//

import Foundation

internal struct ParseToDisplayEventsValidator: LineSyntaxValidator {
    func validate(lineRawText: String, lineNo: Int) -> Result<(), ValidationError> {
        let parser = ScriptParser()

        do {
            _ = try parser.parse(rawString: lineRawText)
            return .success(())
        } catch {
            let tagParseError = error as! TagParseError
            switch tagParseError {
            case .unknownTag(let unknownTagString):
                return .failure(.unknownTag(lineNo: lineNo, tagName: unknownTagString))
            }
        }
    }
}