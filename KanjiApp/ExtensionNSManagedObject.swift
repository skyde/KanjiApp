import UIKit
import CoreData

extension NSManagedObject
{
    class func createEntity (entityName: CoreDataEntities, propertyName:CardProperties, value:String, context: NSManagedObjectContext, checkForExisting: Bool = true) -> Card? {
        
        var matches: NSArray = []
        
        if !value.isEmpty {
            if(checkForExisting)
            {
                let propertyType = propertyName.description()
                
                let request : NSFetchRequest = NSFetchRequest(entityName: entityName.description())
                
                request.returnsObjectsAsFaults = false
                request.predicate = NSPredicate(format: "\(propertyType) = %@", value)
                var error: NSError? = nil
                
                var matches: NSArray = context.executeFetchRequest(request, error: &error)
                
                if (matches.count > 1) {
                    return matches[0] as? Card
                }
            }
            
            let entityDescription = NSEntityDescription.entityForName(entityName.description(), inManagedObjectContext: context)
            var card : Card = Card(entity: entityDescription, insertIntoManagedObjectContext: context)
            
            switch propertyName {
            case .kanji:
                card.kanji = value
            default:
                return card
            }
            return card
        }
        return nil
    }
}