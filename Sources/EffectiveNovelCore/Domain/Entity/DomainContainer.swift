//
// Created by osushi on 2022/11/04.
//

import Foundation
import Factory

// MARK: - Parser
extension Container {
    static var scriptParser = Factory { ScriptParserImpl() as ScriptParser }
}