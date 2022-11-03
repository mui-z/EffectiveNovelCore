//
// Created by osushi on 2022/09/25.
//

import Foundation
import Factory

public struct EFNovelScript {
    @Injected(Container.scriptParser)
    var parser: ScriptParser

    private(set) var displayEvents: [DisplayEvent] = []

    init(events: [DisplayEvent]) {
        displayEvents = events
    }

    // NOTE: For Testable
    init(rawText: String) {
        displayEvents = try! parser.parse(rawString: rawText)
    }
}

