//
// Created by osushi on 2022/10/15.
//

import Foundation

struct NewlineCharacterRemover: PreProcessor {
    func execute(rawAllString: String) -> String {
        var str = rawAllString
        str.removeAll(where: { $0 == "\n"} )
        return str
    }
}
