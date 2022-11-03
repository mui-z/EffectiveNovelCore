//
// Created by osushi on 2022/10/15.
//

import Foundation

internal struct NewlineCharacterRemover: PreProcessor {
    func execute(rawAllString: String) -> String {
        rawAllString.replacingOccurrences(of: "\n", with: "")
    }
}
