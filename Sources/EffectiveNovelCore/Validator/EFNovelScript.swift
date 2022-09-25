//
// Created by osushi on 2022/09/25.
//

import Foundation

public struct EFNovelScript: Equatable {
    private(set) var displayEvents: [DisplayEvent] = []

    internal init(events: [DisplayEvent]) {
        displayEvents = events
    }

    internal init(rawText: String) {
        let parser = ScriptParser()
        displayEvents = try! parser.parse(rawAllString: rawText)
    }

    public static func validate(rawText: String) -> Result<EFNovelScript, ParseError> {
        let parser = ScriptParser()

        do {
            guard rawText.countChar(char: "[") == rawText.countChar(char: "]") else {
                throw ParseError.invalidBracketsPair(message: "brackets pair broken")
            }

            guard rawText.contains("[e]") else { throw ParseError.notFoundEndTag }
            let events = try parser.parse(rawAllString: rawText)

            return .success(EFNovelScript(events: events))
        } catch {
            return .failure(error as! ParseError)
        }
    }
}

private extension String {
    func countChar(char: Character) -> Int {
        filter({ $0 == char }).count
    }
}
