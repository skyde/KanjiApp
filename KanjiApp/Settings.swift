import UIKit
import CoreData

@objc(Settings)
class Settings: NSManagedObject {
    @NSManaged var userName: String
    @NSManaged var cardAddAmount: NSNumber
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var onlyStudyKanji: NSNumber
    @NSManaged var volume: NSNumber
}