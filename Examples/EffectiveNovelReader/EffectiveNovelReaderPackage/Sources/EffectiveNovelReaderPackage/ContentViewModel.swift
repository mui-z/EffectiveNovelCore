//
// Created by osushi on 2022/10/10.
//

import Combine
import EffectiveNovelCore
import Foundation
import Observation

@Observable
@MainActor
final class ContentViewModel {

  var displayText = "let's tap."

  @ObservationIgnored
  private let controller = EFNovelController()

  @ObservationIgnored
  private var cancellables = Set<AnyCancellable>()

  @ObservationIgnored
  private var nowEvent: DisplayEvent?

  init() {
    let result = controller.load(raw: novelText)

    switch result {
    case .valid(let script):
      displayingText(script: script)
    case .invalid:
      displayText = "invalid novel text"
    }
  }

  func tapScreen() {
    switch nowEvent {
    case .tapWait:
      controller.resume()
    case .tapWaitAndNewline:
      displayText += "\n"
      controller.resume()
    default:
      controller.showTextUntilWaitTag()
    }
  }

  private func displayingText(script: EFNovelScript) {
    displayText = ""

    controller.start(script: script)
      .receive(on: RunLoop.main)
      .sink { [unowned self] event in
        nowEvent = event
        handleEvent(event: event)
      }
      .store(in: &cancellables)

  }

  private func handleEvent(event: DisplayEvent) {
    switch event {
    case .character(let char):
      displayText += String(char)
    case .newline:
      displayText += "\n"
    case .clear:
      displayText = ""
    default:
      break
    }
  }
}
