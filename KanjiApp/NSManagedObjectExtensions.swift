import UIKit
import CoreData

extension NSManagedObject
{
    class func createEntity<T: NSManagedObject> (entityName: CoreDataEntities, _ context: NSManagedObjectContext, property:EntityProperties? = nil, value:CVarArg = "") -> T?
    {
        //var matches: NSArray = []
        
//        if !value.isEmpty
//        {
        let request : NSFetchRequest = NSFetchRequest(entityName: entityName.description())
        
        request.returnsObjectsAsFaults = false
        
        if let p = property
        {
            request.predicate = NSPredicate(format: "\(p.description()) = %@", value)
        }
        else
        {
            request.predicate = NSPredicate()
        }
        
        var error: NSError? = nil
        
        var matches: NSArray = context.executeFetchRequest(request, error: &error)
        
        if (matches.count > 1)
        {
            return matches[0] as? T
        }
        
        let entityDescription = NSEntityDescription.entityForName(entityName.description(), inManagedObjectContext: context)
        
        var card = T(entity: entityDescription, insertIntoManagedObjectContext: context)
        
//            switch property {
//            case .kanji:
//                card.kanji = value
//            default:
//                return card
//            }
        return card
//        }
        //return nil
    }
}