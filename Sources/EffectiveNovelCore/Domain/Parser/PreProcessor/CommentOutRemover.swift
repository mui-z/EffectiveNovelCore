//
// Created by osushi on 2022/10/15.
//

import Foundation

struct CommentOutRemover: PreProcessor {
    func execute(rawAllString: String) -> String {
        let tmpReplaceHashChar = "!@@-!@?+@@"

        let lines = rawAllString.split(separator: "\n").map { String($0) }
        let replaceEscapingHashChar = lines.map { $0.replacingOccurrences(of: "\\#", with: tmpReplaceHashChar) }
        let replacedCommentOnlyLinesToBlank = replaceEscapingHashChar.map { $0.first == "#" ? "" : $0 }
        return replacedCommentOnlyLinesToBlank
            .map { $0.contains("#") ? String($0.split(separator: "#").first ?? " ") : String($0) }
            .map { $0.replacingOccurrences(of: tmpReplaceHashChar, with: "#")}
            .joined(separator: "\n")
    }
}
