//
// Created by osushi on 2022/11/04.
//

import Foundation
import Factory

// MARK: - Parser

extension Container {
  static var commentOutRemover = Factory<CommentOutRemoverProtocol> { CommentOutRemover() }
  static var newLineRemover = Factory<NewlineCharacterRemoverProtocol> { NewlineCharacterRemover() }
  
  static var preProcessors = Factory<[PreProcessor]> { [CommentOutRemover(), NewlineCharacterRemover()] }
  
  static var scriptParser = Factory<ScriptParserProtocol> { ScriptParser() }
}

// MARK: - Validator

extension Container {
  static var bracketsPairValidator = Factory<BracketsPairValidatorProtocol> { BracketsPairValidator() }
  static var mustContainsIncludeTagsValidator = Factory<MustContainsIncludeTagsValidatorProtocol> { MustContainsIncludeTagsValidator() }
  static var parseToDisplayEventsValidator = Factory<ParseToDisplayEventsValidatorProtocol> { ParseToDisplayEventsValidator() }
  
  static var lineSyntaxValidators = Factory<[LineSyntaxValidatorProtocol]> { [BracketsPairValidator(), ParseToDisplayEventsValidator()] }
  static var allStringSyntaxValidators = Factory<[AllStringSyntaxValidatorProtocol]> { [MustContainsIncludeTagsValidator()] }
}
