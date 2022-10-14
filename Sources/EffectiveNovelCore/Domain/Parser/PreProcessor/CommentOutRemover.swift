//
// Created by osushi on 2022/10/15.
//

import Foundation

struct CommentOutRemover: PreProcessor {
    func execute(rawAllString: String) -> String {
        let lines = rawAllString.split(separator: "\n").map { String($0) }
        let replacedCommentOnlyLinesToBlank = lines.map { $0.first == "#" ? "" : $0 }
        return replacedCommentOnlyLinesToBlank
            .map { $0.contains("#") ? String($0.split(separator: "#").first ?? " ") : String($0) }
            .joined(separator: "\n")
    }
}
