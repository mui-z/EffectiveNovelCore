//
// Created by osushi on 2022/09/28.
//

import Foundation

protocol MustContainsIncludeTagsValidatorProtocol: AllStringSyntaxValidatorProtocol {}

struct MustContainsIncludeTagsValidator: MustContainsIncludeTagsValidatorProtocol {
  func validate(allStringRawText: String) -> Result<Void, ValidationError> {
    let mustContainsTags: [DisplayEvent] = [.end]
    let notFoundTags = mustContainsTags
      .filter { !allStringRawText.contains("[\($0.rawTagString())]") }
    
    return notFoundTags.isEmpty ? .success(()) : .failure(.notFoundMustIncludeTag(notFoundTags: notFoundTags))
  }
}
