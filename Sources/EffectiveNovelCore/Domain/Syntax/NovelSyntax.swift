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
    case wait(duration: Double)
    case end
}
