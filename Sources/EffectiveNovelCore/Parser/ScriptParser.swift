//
// Created by osushi on 2022/09/23.
//

import Foundation

protocol Parser {
    func parse(rawAllString: String) -> [DisplayEvent]
}

struct ScriptParser: Parser {
    func parse(rawAllString raw: String) -> [DisplayEvent] {
        var rawAllString = raw
        rawAllString.removeAll(where: { $0 == "\n" })

        return rawAllString.components(separatedBy: "[")
                           .filter { !$0.isEmpty }
                           .map { (raw: $0, isCommandInclude: $0.contains("]")) }
                           .map { $0.isCommandInclude ? splitCommandIncludingText(raw: $0.raw) : stringToCharacter(string: $0.raw) }
                           .flatMap { $0 }
    }

    //  cm] or cm]text
    private func splitCommandIncludingText(raw: String) -> [DisplayEvent] {
        var result: [DisplayEvent] = []
        let commandAndText = raw.components(separatedBy: "]")

        result.append(DisplayEvent.parseCommand(rawCommand: commandAndText.first!))

        if let text = commandAndText.last, !text.isEmpty {
            result += stringToCharacter(string: text)
        }

        return result
    }

    private func stringToCharacter(string: String) -> [DisplayEvent] {
        string.map { c in DisplayEvent.character(char: c) }
    }
}
