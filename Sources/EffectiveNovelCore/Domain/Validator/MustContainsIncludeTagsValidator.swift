//
// Created by osushi on 2022/09/28.
//

import Foundation

protocol MustContainsIncludeTagsValidatorProtocol: AllStringSyntaxValidatorProtocol {}

struct MustContainsIncludeTagsValidator: MustContainsIncludeTagsValidatorProtocol {
  func validate(allStringRawText: String) -> Result<Void, ValidationError> {
    var notFoundTags = [DisplayEvent]()
    
    if !(allStringRawText.contains("[e]")) {
      notFoundTags.append(.end)
    }
    
    return notFoundTags.isEmpty ? .success(()) : .failure(.notFoundMustIncludeTag(notFoundTags: notFoundTags))
  }
}
