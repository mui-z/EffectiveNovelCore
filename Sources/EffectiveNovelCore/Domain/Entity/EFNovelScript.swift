//
// Created by osushi on 2022/09/25.
//

import Foundation

public struct EFNovelScript: Equatable {
    private(set) var displayEvents: [DisplayEvent] = []

    internal init(events: [DisplayEvent]) {
        displayEvents = events
    }

    // NOTE: For Testable
    internal init(rawText: String) {
        let parser = ScriptParser()
        displayEvents = try! parser.parse(rawString: rawText)
    }
}

