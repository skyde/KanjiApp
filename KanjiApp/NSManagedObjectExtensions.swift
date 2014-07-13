import UIKit
import CoreData

extension NSManagedObject
{
    class func createEntity (entityName: CoreDataEntities, _ context: NSManagedObjectContext, property:String? = nil, value:String = "") -> NSManagedObject?
    {
        var matches: NSArray = []
        
        if !value.isEmpty
        {
            let request : NSFetchRequest = NSFetchRequest(entityName: entityName.description())
            
            request.returnsObjectsAsFaults = false
            
            if let p = property
            {
                request.predicate = NSPredicate(format: "\(p) = %@", value)
            }
            
            var error: NSError? = nil
            
            var matches: NSArray = context.executeFetchRequest(request, error: &error)
            
            if (matches.count > 1)
            {
                return matches[0] as? Card
            }
            
            let entityDescription = NSEntityDescription.entityForName(entityName.description(), inManagedObjectContext: context)
            
            var card : Card = Card(entity: entityDescription, insertIntoManagedObjectContext: context)
            
//            switch property {
//            case .kanji:
//                card.kanji = value
//            default:
//                return card
//            }
            return card
        }
        return nil
    }
}