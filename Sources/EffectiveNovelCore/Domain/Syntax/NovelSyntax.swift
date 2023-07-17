//
// Created by osushi on 2022/09/23.
//

public enum ValidationError: Error, Equatable {
  case unknownTag(lineNo: Int, tagName: String)
  case invalidBracketsPair(lineNo: Int)
  case notFoundMustIncludeTag(notFoundTags: [DisplayEvent])
}

enum TagParseError: Error, Equatable {
  case unknownTag(unknownTag: String)
}

public enum DisplayEvent: Equatable {
  case character(char: Character)
  case setDefaultDelay(speed: Double)
  case newline
  case tapWait
  case tapWaitAndNewline
  case clear
  case resetDelay
  case delay(speed: Double)
  case sleep(duration: Double)
  case end
}

extension DisplayEvent {
  func rawTagString() -> String {
    switch self {
      case .newline:
        return "n"
      case .tapWait:
        return "tw"
      case .tapWaitAndNewline:
        return "twn"
      case .clear:
        return "cl"
      case .resetDelay:
        return "resetDelay"
      case .setDefaultDelay:
        return "setDefaultDelay"
      case .delay:
        return "delay"
      case .sleep:
        return "sleep"
      case .end:
        return "e"
      case .character(char: let char):
        return String(char)
    }
  }
}
