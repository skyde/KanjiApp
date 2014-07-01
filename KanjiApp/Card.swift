import UIKit
import CoreData

enum CardProperties {
    case kanji
    case index
    case hiragana
    case definition
    case exampleEnglish
    case exampleJapanese
    case soundWord
    case soundDefinition
    case definitionOther
    case usageAmount
    case usageAmountOther
    case pitchAccentText
    case pitchAccent
    case otherExampleSentences
    
    case answersKnown
    case answersNormal
    case answersHard
    case answersForgot
    case interval
    func description() -> String {
        switch self {
        case .kanji:
            return "kanji"
        case .index:
            return "index"
        case .hiragana:
            return "hiragana"
        case .definition:
            return "definition"
        case .exampleEnglish:
            return "exampleEnglish"
        case .exampleJapanese:
            return "exampleJapanese"
        case .soundWord:
            return "soundWord"
        case .soundDefinition:
            return "soundDefinition"
        case .definitionOther:
            return "definitionOther"
        case .definitionOther:
            return "definitionOther"
        case .usageAmount:
            return "usageAmount"
        case .usageAmountOther:
            return "usageAmountOther"
        case .pitchAccentText:
            return "pitchAccentText"
        case .pitchAccent:
            return "pitchAccent"
        case .otherExampleSentences:
            return "otherExampleSentences"
        case .answersKnown:
            return "answersKnown"
        case .answersNormal:
            return "answersNormal"
        case .answersHard:
            return "answersHard"
        case .answersForgot:
            return "answersForgot"
        case .interval:
            return "interval"
        }
    }
}

@objc(Card)
class Card: NSManagedObject {
    @NSManaged var kanji: String
    @NSManaged var index: NSNumber
    @NSManaged var hiragana: String
    @NSManaged var definition: String
    @NSManaged var exampleEnglish: String
    @NSManaged var exampleJapanese: String
    @NSManaged var soundWord: String
    @NSManaged var soundDefinition: String
    @NSManaged var definitionOther: String
    @NSManaged var usageAmount: NSNumber
    @NSManaged var usageAmountOther: NSNumber
    @NSManaged var pitchAccentText: String
    @NSManaged var pitchAccent: NSNumber
    @NSManaged var otherExampleSentences: String

    @NSManaged var answersKnown: NSNumber
    @NSManaged var answersNormal: NSNumber
    @NSManaged var answersHard: NSNumber
    @NSManaged var answersForgot: NSNumber
    @NSManaged var interval: NSNumber

//
//// CREATE CLASS OBJECT
//
    
    class func createCard (propertyName:CardProperties, value:String, context: NSManagedObjectContext) -> Card? {
        if !value.isEmpty {
            let propertyType = propertyName.description()
            
            let entityName = "Card"
            let request : NSFetchRequest = NSFetchRequest(entityName: entityName)
            
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "\(propertyType) = %@", value)
            var error: NSError? = nil
            
            var matches: NSArray = context.executeFetchRequest(request, error: &error)
            
            println("Number of Matches \(matches.count)")
            for match : AnyObject in matches
            {
                println("Fetch from Core Data /(match)")
            }
//            
//            println(error)
//
            if (matches.count > 1) {
                // handle error
                return matches[0] as? Card
            } else if matches.count ==  0 {
                let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
                var card : Card = Card(entity: entityDescription, insertIntoManagedObjectContext: context)
                
                switch propertyName {
                    case .kanji:
                            card.kanji = value
                    default:
                        return card
                }
                return card
            }
            else {
                println(matches[0])
                return matches[0] as? Card
            }
        }
        return nil
    }
}

//
//// FETCH REQUESTS
//

func myGeneralFetchRequest (entity : CoreDataEntities,
    property : CardProperties,
    context : NSManagedObjectContext) -> AnyObject[]?{
        
        let entityName = entity.description()
        let propertyName = property.description()
        
        let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: propertyName, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        var error: NSError? = nil
        var matches: NSArray = context.executeFetchRequest(request, error: &error)
        
        if matches.count > 0 {
            return matches
        }
        else {
            return nil
        }
}

func myNameFetchRequest (entity : CoreDataEntities,
    property : CardProperties,
    value : String,
    context : NSManagedObjectContext) -> AnyObject[]? {
        
        let entityName = entity.description()
        let propertyName = property.description()
        
        let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "\(propertyName) = %@", value)
        let sortDescriptor :NSSortDescriptor = NSSortDescriptor(key: propertyName, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        var error: NSError? = nil
        var matches: NSArray = context.executeFetchRequest(request, error: &error)
        
        if matches.count > 0 {
            return matches
        }
        else {
            return nil
        }
}

//
//// PRINT FETCH REQUEST
//

func printFetchedArrayList (myarray:AnyObject[]) {
    if myarray.count > 0 {
        println("Has \(myarray.count) object")
        for card : AnyObject in myarray {
            var anObject = card as Card
            //var thekanji = anObject.kanji
            //println(thekanji)
        }
    }
    else {
        println("empty fetch")
    }
}