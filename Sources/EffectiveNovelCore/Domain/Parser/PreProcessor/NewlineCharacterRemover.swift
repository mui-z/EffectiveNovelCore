//
// Created by osushi on 2022/10/15.
//

import Foundation

protocol NewlineCharacterRemoverProtocol: PreProcessor {}

struct NewlineCharacterRemover: NewlineCharacterRemoverProtocol {
    func execute(rawAllString: String) -> String {
        rawAllString.replacingOccurrences(of: "\n", with: "")
    }
}
