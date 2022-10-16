//
// Created by osushi on 2022/10/16.
//

import Foundation
import Factory

extension Container {
    static var lineSyntaxValidators = Factory<[LineSyntaxValidator]> { [BracketsPairValidator(), ParseToDisplayEventsValidator()] }
    static var allStringSyntaxValidators = Factory<[AllStringSyntaxValidator]> { [MustContainsIncludeTagsValidator()] }
}
