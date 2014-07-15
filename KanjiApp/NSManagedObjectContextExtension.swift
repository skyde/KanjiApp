import UIKit
import CoreData

extension NSManagedObjectContext
{
    func createEntity<T: NSManagedObject> (entity: CoreDataEntities, _ property:EntityProperties? = nil, _ value:CVarArg = "") -> T?
    {
        //var matches: NSArray = []
        
        //        if !value.isEmpty
        //        {
        let request : NSFetchRequest = NSFetchRequest(entityName: entity.description())
        
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
        
//        self.executeFetchRequest(NSManagedObjectContext))
        
        var matches: NSArray = self.executeFetchRequest(request, error: &error)
        
        if (matches.count > 0)
        {
            return matches[0] as? T
        }
        
        let entityDescription = NSEntityDescription.entityForName(entity.description(), inManagedObjectContext: self)
        
        var card = T(entity: entityDescription, insertIntoManagedObjectContext: self)
        
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
    
    func fetchEntitiesGeneral (entity : CoreDataEntities, sortProperty : EntityProperties, sortAscending: Bool = true) -> [NSManagedObject]?{
        
        let entityName = entity.description()
        //let propertyName = property.description()
        
        let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: sortProperty.description(), ascending: true)
        request.sortDescriptors = [sortDescriptor]
        var error: NSError? = nil
        var matches: NSArray = self.executeFetchRequest(request, error: &error)
        
        if matches.count > 0 {
//            if var castMatches is [NSManagedObject]
//            {
//                
//            }
            return matches as [NSManagedObject]
        }
        else {
            return nil
        }
    }

    func fetchCards (property : CardProperties,
        value : String,
        context : NSManagedObjectContext) -> [AnyObject]? {
            
            let entity = CoreDataEntities.Card
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

    func fetchCardByKanji(kanji: String) -> Card
    {
        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji)
        
        return value as Card
    }

    func fetchCardByIndex(index: NSNumber) -> Card
    {
        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.index, index)
        
        return value as Card
    }

    func fetchEntity (entity : CoreDataEntities, _ property : EntityProperties, _ value : NSObject) -> AnyObject? {
        
        //let entity = CoreDataEntities.Card
        let entityName = entity.description()
        let propertyName = property.description()
        
        let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "\(propertyName) = %@", value)
        let sortDescriptor :NSSortDescriptor = NSSortDescriptor(key: propertyName, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        var error: NSError? = nil
        var matches: NSArray = self.executeFetchRequest(request, error: &error)
        
        if matches.count > 0 {
            return matches[0]
        }
        else {
            return nil
        }
    }
}
//
//// PRINT FETCH REQUEST
//

//func printFetchedArrayList (myarray:AnyObject[]) {
//    if myarray.count > 0 {
//        println("Has \(myarray.count) object")
//        for card : AnyObject in myarray {
//            var anObject = card as Card
//            //var thekanji = anObject.kanji
//            //println(thekanji)
//        }
//    }
//    else {
//        println("empty fetch")
//    }
//}