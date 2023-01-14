//
// Created by osushi on 2022/10/15.
//

import Foundation
import XCTest

@testable import EffectiveNovelCore

class CommentOutRemoverTest: XCTestCase {

    func testRemoveComment() {
        let processor = CommentOutRemover()
        let target = """
                     # comment
                     #comment
                     aaa b# comment ooo
                     aaa# comment
                     aaa #comment
                     bbb##comment
                     ccc## comment
                     #
                     ##
                     normal
                     aaa\\#bbb#ccc
                     """

        let expect = """


                     aaa b
                     aaa
                     aaa 
                     bbb
                     ccc


                     normal
                     aaa#bbb
                     """
        XCTAssertEqual(processor.execute(rawAllString: target), expect)
    }
}
