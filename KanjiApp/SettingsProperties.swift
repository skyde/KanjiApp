import Foundation

enum SettingsProperties {
    case cardAddAmount
    case jlptLevel
    case onlyStudyKanji
    case volume
    
    func description() -> String {
        switch self {
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