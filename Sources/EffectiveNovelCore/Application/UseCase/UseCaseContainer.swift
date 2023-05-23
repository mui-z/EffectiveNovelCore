//
// Created by osushi on 2022/10/09.
//

import Foundation
import Factory

extension Container {
  static var validateScriptUseCase = Factory<ValidateScriptUseCaseProtocol> { ValidateScriptUseCase() }
}
