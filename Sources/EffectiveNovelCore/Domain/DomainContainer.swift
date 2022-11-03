//
// Created by osushi on 2022/11/04.
//

import Foundation
import Factory

// MARK: - Parser
extension Container {
    static var scriptParser = Factory { ScriptParserImpl() as ScriptParser }
    static var preProcessors = Factory<[PreProcessor]> { [CommentOutRemover(), NewlineCharacterRemover()] }
}

// MARK: - Validator
extension Container {
    static var lineSyntaxValidators = Factory<[LineSyntaxValidator]> { [BracketsPairValidator(), ParseToDisplayEventsValidator()] }
    static var allStringSyntaxValidators = Factory<[AllStringSyntaxValidator]> { [MustContainsIncludeTagsValidator()] }
}
