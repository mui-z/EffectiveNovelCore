//
// Created by osushi on 2022/09/25.
//

import Foundation
import Factory

public struct EFNovelScript {
    @Injected(Container.scriptParser)
    var parser: ScriptParser

    private(set) var displayEvents: [DisplayEvent] = []

    internal init(events: [DisplayEvent]) {
        displayEvents = events
    }

    // NOTE: For Testable
    internal init(rawText: String) {
        displayEvents = try! parser.parse(rawString: rawText)
    }
}

