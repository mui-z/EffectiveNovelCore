//
// Created by osushi on 2022/11/04.
//

import Foundation
import XCTest

@testable import EffectiveNovelCore

class NewlineCharacterRemoverTest: XCTestCase {

    func testRemoveNewline() {
        let processor = NewlineCharacterRemover()
        let target = """
                     aaa
                     bbb
                     cc

                     dd
                     e e
                     """

        let expect = """
                     aaabbbccdde e
                     """

        XCTAssertEqual(processor.execute(rawAllString: target), expect)
    }
}
