import Foundation
import UIKit

enum View {
    case Search
    case GameMode
    case Reader
    case CardsFinished
    case AddWords
    case Lists(title: String, color: UIColor, cards: [NSNumber], displayAddButton: Bool, enableOnAdd: Bool)
    case Settings
    
    func description() -> String {
        switch self {
        case .Search:
            return "Search"
        case .GameMode:
            return "GameMode"
        case .Reader:
            return "Reader"
        case .CardsFinished:
            return "CardsFinished"
        case .AddWords:
            return "AddWords"
        case .Lists:
            return "Lists"
        case .Settings:
            return "Settings"
        }
    }
}