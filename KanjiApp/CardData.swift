import Foundation
import UIKit
import CoreData

@objc(CardData)
class CardData: NSManagedObject {
    
    @NSManaged var definition: String
    @NSManaged var definitionOther: String
    @NSManaged var exampleEnglish: String
    @NSManaged var exampleJapanese: String
    @NSManaged var otherExampleSentences: String
    @NSManaged var pitchAccent: NSNumber
    @NSManaged var pitchAccentText: String
    @NSManaged var soundDefinition: String
    @NSManaged var soundWord: String
    @NSManaged var parent: Card
    @NSManaged var answersKnown: NSNumber
    @NSManaged var answersNormal: NSNumber
    @NSManaged var answersHard: NSNumber
    @NSManaged var answersForgot: NSNumber
    @NSManaged var displayFrontAsHiragana: NSNumber
}