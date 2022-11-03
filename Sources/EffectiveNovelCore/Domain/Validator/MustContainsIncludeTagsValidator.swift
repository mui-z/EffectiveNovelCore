//
// Created by osushi on 2022/09/28.
//

import Foundation

struct MustContainsIncludeTagsValidator: AllStringSyntaxValidator {
    func validate(allStringRawText: String) -> Result<(), ValidationError> {
        var notFoundTags = [DisplayEvent]()

        if !(allStringRawText.contains("[e]")) {
            notFoundTags.append(.end)
        }

        return notFoundTags.isEmpty ? .success(()) : .failure(.notFoundMustIncludeTag(notFoundTags: notFoundTags))
    }
}
