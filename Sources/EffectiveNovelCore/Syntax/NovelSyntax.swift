//
// Created by osushi on 2022/09/23.
//

public enum DisplayEvent: Equatable {
    case character(char: Character)
    case newline
    case tapWait
    case tapWaitAndNewline
    case clear

    case resetDelay
    case delay(speed: Double)

    case end

    static func parseCommand(rawCommand: String) -> DisplayEvent {
        switch rawCommand {
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
        case (let command) where command.contains("delay"):
            let speed = Double(command.split(separator: "=").last!)!
            return .delay(speed: speed)
        case "e":
            return .end
        default:
            fatalError(file: #file)
        }
    }
}
