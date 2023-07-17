//
// Created by osushi on 2022/09/30.
//

import Foundation
import Factory

public enum ValidationResult<SUCCESS, ERROR> {
  case valid(SUCCESS)
  case invalid(ERROR)
}

protocol ValidateScriptUseCaseProtocol {
  func validate(rawAllString: String) -> ValidationResult<EFNovelScript, [ValidationError]>
}

struct ValidateScriptUseCase: ValidateScriptUseCaseProtocol {
  
  @Injected(\.lineSyntaxValidators)
  var lineSyntaxValidators: [LineSyntaxValidatorProtocol]
  
  @Injected(\.allStringSyntaxValidators)
  var allStringSyntaxValidators: [AllStringSyntaxValidatorProtocol]
  
  @Injected(\.scriptParser)
  var parser: ScriptParserProtocol
  
  func validate(rawAllString: String) -> ValidationResult<EFNovelScript, [ValidationError]> {
    
    var validationResults = [Result<Void, ValidationError>]()
    
    validationResults += lineSyntaxValidate(rawAllString: rawAllString)
    validationResults += allStringSyntaxValidate(allString: rawAllString)
    
    let isSuccess = validationResults
      .allSatisfy { $0.isSuccess }
    
    if isSuccess {
      let displayEvents = try! parser.parse(rawString: rawAllString)
      return .valid(.init(displayEvents: displayEvents))
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
  
  private func lineSyntaxValidate(rawAllString: String) -> [Result<Void, ValidationError>] {
    
    let lines: [String] = rawAllString.split(separator: "\n").map { String($0) }
    
    var validationResults = [Result<Void, ValidationError>]()
    
    for (index, line) in lines.enumerated() {
      // NOTE: to one origin
      let fixedIndex = index + 1
      validationResults += lineSyntaxValidators.map { $0.validate(lineRawText: line, lineNo: fixedIndex) }
    }
    
    return validationResults
  }
  
  private func allStringSyntaxValidate(allString: String) -> [Result<Void, ValidationError>] {
    allStringSyntaxValidators.map { $0.validate(allStringRawText: allString) }
  }
}

private extension Result {
  var isSuccess: Bool {
    // FIXME: very redundant code
    if case .success = self {
      return true
    } else {
      return false
    }
  }
  
  var isError: Bool {
    !isSuccess
  }
}
