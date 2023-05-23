//
// Created by osushi on 2022/09/25.
//

import Foundation
import Factory

public struct EFNovelScript {
  private(set) var displayEvents: [DisplayEvent] = []
  
  init(events: [DisplayEvent]) {
    displayEvents = events
  }
}
