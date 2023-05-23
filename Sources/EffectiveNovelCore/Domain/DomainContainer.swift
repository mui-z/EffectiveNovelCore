//
// Created by osushi on 2022/11/04.
//

import Foundation
import Factory

// MARK: - Parser

extension Container {
  var commentOutRemover: Factory<CommentOutRemoverProtocol> { self { CommentOutRemover() } }
  var newLineRemover: Factory<NewlineCharacterRemoverProtocol> { self { NewlineCharacterRemover() } }
  
  var preProcessors: Factory<[PreProcessor]> { self { [CommentOutRemover(), NewlineCharacterRemover()] } }
  
  var scriptParser: Factory<ScriptParserProtocol> { self { ScriptParser() } }
}

// MARK: - Validator

extension Container {
  var bracketsPairValidator: Factory<BracketsPairValidatorProtocol> { self { BracketsPairValidator() } }
  var mustContainsIncludeTagsValidator: Factory<MustContainsIncludeTagsValidatorProtocol> { self { MustContainsIncludeTagsValidator() } }
  var parseToDisplayEventsValidator: Factory<ParseToDisplayEventsValidatorProtocol> { self { ParseToDisplayEventsValidator() } }

  var lineSyntaxValidators: Factory<[LineSyntaxValidatorProtocol]> { self { [BracketsPairValidator(), ParseToDisplayEventsValidator()] } }
  var allStringSyntaxValidators: Factory<[AllStringSyntaxValidatorProtocol]> { self { [MustContainsIncludeTagsValidator()] } }
}
