//
// Created by osushi on 2022/10/09.
//

import Factory
import Foundation

extension Container {
  var validateScriptUseCase: Factory<ValidateScriptUseCaseProtocol> {
    self {
      ValidateScriptUseCase(
        lineSyntaxValidators: self.lineSyntaxValidators(),
        allStringSyntaxValidators: self.allStringSyntaxValidators(),
        parser: self.scriptParser()
      )
    }
  }
}
