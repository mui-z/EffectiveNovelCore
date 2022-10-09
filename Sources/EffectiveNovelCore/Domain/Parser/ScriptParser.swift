//
// Created by osushi on 2022/09/23.
//

import Foundation

internal protocol Parser {
    func parse(rawString: String) throws -> [DisplayEvent]
}

internal struct ScriptParser: Parser {
    func parse(rawString raw: String) throws -> [DisplayEvent] {
        var rawAllString = raw
        rawAllString.removeAll(where: { $0 == "\n" })

        do {
            let events = try rawAllString.components(separatedBy: "[")
                                         .filter { !$0.isEmpty }
                                         .map { (raw: $0, isTagInclude: $0.contains("]")) }
                                         .map { $0.isTagInclude ? try splitTagIncludingText(raw: $0.raw) : stringToCharacter(string: $0.raw) }
                                         .flatMap { $0 }

            return events
        } catch {
            throw error
        }
    }

    //  n] or n]text
    private func splitTagIncludingText(raw: String) throws -> [DisplayEvent] {
        var result: [DisplayEvent] = []
        let TagAndText = raw.components(separatedBy: "]")

        do {
            try result.append(parseTag(rawTag: TagAndText.first!))
        } catch {
            throw error
        }

        if let text = TagAndText.last, !text.isEmpty {
            result += stringToCharacter(string: text)
        }

        return result
    }

    private func stringToCharacter(string: String) -> [DisplayEvent] {
        string.map { c in DisplayEvent.character(char: c) }
    }

    private func parseTag(rawTag: String) throws -> DisplayEvent {
        switch rawTag {
        case "n":
            return .newline
        case "tw":
            return .tapWait
        case "twn":
            return .tapWaitAndNewline
        case "cl":
            return .clear
        case "resetdelay":
            return .resetDelay
        case (let tag) where tag.hasPrefix("setdefaultdelay"):
            let speed = Double(tag.split(separator: "=").last!)!
            return .setDefaultDelay(speed: speed)
        case (let tag) where tag.hasPrefix("delay speed"):
            let speed = Double(tag.split(separator: "=").last!)!
            return .delay(speed: speed)
        case "e":
            return .end
        default:
            throw TagParseError.unknownTag(unknownTag: rawTag)
        }
    }
}