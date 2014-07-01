import UIKit
import CoreData

enum CardProperties {
    case name
    case kanji
    case interval
    func description() -> String {
        switch self {
        case .name:
            return "name"
        case .kanji:
            return "kanji"
        case .interval:
            return "interval"
        }
    }
}

@objc(Card)
class Card: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var kanji: String
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