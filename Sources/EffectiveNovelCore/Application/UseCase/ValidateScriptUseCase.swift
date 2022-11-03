//
// Created by osushi on 2022/09/30.
//

import Foundation
import Factory

public enum ValidateResult<SUCCESS, ERROR> {
    case valid(SUCCESS)
    case invalid(ERROR)
}

protocol ValidateScriptUseCase {
    func validate(rawAllString: String) -> ValidateResult<EFNovelScript, [ValidationError]>
}

struct ValidateScriptUseCaseImpl: ValidateScriptUseCase {

    @Injected(Container.lineSyntaxValidators)
    var lineSyntaxValidators: [LineSyntaxValidator]

    @Injected(Container.allStringSyntaxValidators)
    var allStringSyntaxValidators: [AllStringSyntaxValidator]

    @Injected(Container.scriptParser)
    var parser: ScriptParser

    func validate(rawAllString: String) -> ValidateResult<EFNovelScript, [ValidationError]> {

        var validationResults = [Result<(), ValidationError>]()

        validationResults += lineSyntaxValidate(rawAllString: rawAllString)
        validationResults += allStringSyntaxValidate(allString: rawAllString)

        let isSuccess = validationResults
            .allSatisfy { $0.isSuccess }

        if isSuccess {
            let displayEvents = try! parser.parse(rawString: rawAllString)
            return .valid(EFNovelScript(events: displayEvents))
        } else {
            var errors = [ValidationError]()
            validationResults.forEach { result in
                if case let .failure(error) = result {
                    errors.append(error)
                }
            }
            return .invalid(errors)
        }

    }

    private func lineSyntaxValidate(rawAllString: String) -> [Result<(), ValidationError>] {

        let lines: [String] = rawAllString.split(separator: "\n").map { String($0) }

        var validationResults = [Result<(), ValidationError>]()

        for (index, line) in lines.enumerated() {
            // NOTE: to one origin
            let fixedIndex = index + 1
            validationResults += lineSyntaxValidators.map { $0.validate(lineRawText: line, lineNo: fixedIndex) }
        }

        return validationResults
    }

    private func allStringSyntaxValidate(allString: String) -> [Result<(), ValidationError>] {
        allStringSyntaxValidators.map { $0.validate(allStringRawText: allString) }
    }

}

private extension Result {
    var isSuccess: Bool {
        if case .success = self { return true } else { return false }
    }

    var isError: Bool {
        !isSuccess
    }
}
