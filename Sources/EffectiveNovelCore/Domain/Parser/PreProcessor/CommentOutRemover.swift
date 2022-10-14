//
// Created by osushi on 2022/10/15.
//

import Foundation

struct CommentRemover: PreProcessor {
    func execute(rawAllString: String) -> String {
        let lines = rawAllString.split(separator: "\n").map { String($0) }
        return lines.map {
                 $0.contains("#") ? String($0.split(separator: "#").first!) : $0
             }
             .joined(separator: "\n")
    }
}
