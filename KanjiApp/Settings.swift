import UIKit
import CoreData

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

@objc(Settings)
class Settings: NSManagedObject {
    @NSManaged var cardAddAmount: NSNumber
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var onlyStudyKanji: NSNumber
    @NSManaged var volume: NSNumber
}