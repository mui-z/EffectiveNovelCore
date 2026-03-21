//
// Same sample script as Examples/EffectiveNovelReader (NovelText.swift).
//

import Foundation

enum NovelSampleScript {
  static let text = """
                [setDefaultDelay speed=70]
                tap waiting and newline[tw][n]

                [cl] cleared text.[n]

                very fast stream after this text[delay speed=20][n]

                fast displaying!!!!!![n]

                [resetDelay]reset delay speed.[n]

                end.[e]
                """
}
