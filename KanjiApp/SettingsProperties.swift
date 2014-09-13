import Foundation

enum SettingsProperties: EntityProperties {
    case userName
    case cardAddAmount
    case jlptLevel
    case onlyStudyKanji
    case volume
    case generatedCards
    case readerText
    case romajiEnabled
    case seenTutorial
    case textSize
    case furiganaEnabled
    
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
        case .generatedCards:
            return "generatedCards"
        case .readerText:
            return "readerText"
        case .romajiEnabled:
            return "romajiEnabled"
        case .seenTutorial:
            return "seenTutorial"
        case .textSize:
            return "textSize"
        case .furiganaEnabled:
            return "furiganaEnabled"
        }
    }
}