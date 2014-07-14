import Foundation

enum SettingsProperties: EntityProperties {
    case userName
    case cardAddAmount
    case jlptLevel
    case onlyStudyKanji
    case volume
    
    func description() -> String {
        switch self {
        case .userName:
            return "userName"
        case .cardAddAmount:
            return "cardAddAmount"
        case .jlptLevel:
            return "jlptLevel"
        case .onlyStudyKanji:
            return "onlyStudyKanji"
        case .volume:
            return "volume"
        }
    }
}