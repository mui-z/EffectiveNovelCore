//
// Created by osushi on 2022/10/09.
//

import Foundation
import Factory

extension Container {
  var validateScriptUseCase: Factory<ValidateScriptUseCaseProtocol> { self { ValidateScriptUseCase() } }
}
