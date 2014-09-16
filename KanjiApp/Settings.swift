import UIKit
import CoreData

@objc(Settings)
class Settings: NSManagedObject {
    @NSManaged var userName: String
    @NSManaged var cardAddAmount: NSNumber
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var onlyStudyKanji: NSNumber
    @NSManaged var volume: NSNumber
    @NSManaged var generatedCards: NSNumber
    @NSManaged var readerText: String
    @NSManaged var romajiEnabled: NSNumber
    @NSManaged var seenTutorial: NSNumber
    @NSManaged var textSize: NSNumber
    @NSManaged var furiganaEnabled: NSNumber
    @NSManaged var hideTutorialButton: NSNumber
    @NSManaged var hideSidebarButton: NSNumber
    @NSManaged var undoSwipeEnabled: NSNumber
    @NSManaged var reviewAheadAmount: NSNumber
    @NSManaged var todayTime: NSNumber
    @NSManaged var todayTotalStudied: NSNumber
    @NSManaged var cardFrontAsHiragana: NSNumber
}