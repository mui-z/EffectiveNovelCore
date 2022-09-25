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
        do {
            let parser = ScriptParser()
            let events = try parser.parse(rawAllString: rawText)
            return .success(EFNovelScript(events: events))
        } catch {
            return .failure(error as! ParseError)
        }
    }
}
