//
// Created by osushi on 2022/09/23.
//

import Foundation
import Factory

protocol ScriptParserProtocol {
  func parse(rawString: String) throws -> [DisplayEvent]
}

struct ScriptParser: ScriptParserProtocol {
  func parse(rawString raw: String) throws -> [DisplayEvent] {
    let preProcessedString = preProcess(raw: raw)
    
    do {
      return try parseToDisplayEvents(preProcessedString: preProcessedString)
    } catch {
      throw error
    }
  }
  
  private func preProcess(raw: String) -> String {
    @Injected(\.preProcessors)
    var preProcessors: [PreProcessor]
    
    return preProcessors.reduce(raw) { $1.execute(rawAllString: $0) }
  }
  
  private func parseToDisplayEvents(preProcessedString: String) throws -> [DisplayEvent] {
    try preProcessedString.components(separatedBy: "[")
      .filter { !$0.isEmpty }
      .map { (raw: $0, isTagInclude: $0.contains("]")) }
      .map { $0.isTagInclude ? try splitTagIncludingText(raw: $0.raw) : stringToCharacter(string: $0.raw) }
      .flatMap { $0 }
  }
  
  //  n] or n]text
  
  private func splitTagIncludingText(raw: String) throws -> [DisplayEvent] {
    var result: [DisplayEvent] = []
    let tagAndText = raw.components(separatedBy: "]")
    
    do {
      try result.append(parseTag(rawTag: tagAndText.first!))
    } catch {
      throw error
    }
    
    if let text = tagAndText.last, !text.isEmpty {
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
      case "resetDelay":
        return .resetDelay
      case (let tag) where tag.hasPrefix("setDefaultDelay speed"):
        let speed = Double(tag.split(separator: "=").last!)!
        return .setDefaultDelay(speed: speed)
      case (let tag) where tag.hasPrefix("delay speed"):
        let speed = Double(tag.split(separator: "=").last!)!
        return .delay(speed: speed)
      case (let tag) where tag.hasPrefix("sleep duration"):
        let duration = Double(tag.split(separator: "=").last!)!
        return .sleep(duration: duration)
      case "e":
        return .end
      default:
        throw TagParseError.unknownTag(unknownTag: rawTag)
    }
  }
}
