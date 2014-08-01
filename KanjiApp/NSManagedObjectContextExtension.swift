import UIKit
import CoreData

extension NSManagedObjectContext
{
    func fetchEntity<T: NSManagedObject> (entity: CoreDataEntities, _ property:EntityProperties? = nil, _ value:CVarArg = "", var createIfNil: Bool = false) -> T? {
        let request : NSFetchRequest = NSFetchRequest(entityName: entity.description())
        
        request.returnsObjectsAsFaults = false
        
        if let p = property {
            request.predicate = NSPredicate(format: "\(p.description()) = %@", value)
        }
        else {
            request.predicate = NSPredicate()
        }
        
        var error: NSError? = nil
        
        var matches: NSArray = self.executeFetchRequest(request, error: &error)
        
        if matches.count > 0 {
            return matches[0] as? T
        }
        
        if !createIfNil && matches.count == 0 {
            return nil
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
    func fetchEntities(entity: CoreDataEntities, _ predicates: [(EntityProperties, String)], _ sortProperty: EntityProperties, sortAscending: Bool = true) -> [NSManagedObject] {
        var search = ""
        var and = ""
        
        for predicate in predicates
        {
            search += and
            
            search += "("
            search += "\(predicate.0.description()) == \(predicate.1)"
            search += ")"
            
            and = " AND "
        }
        
        return fetchEntities(entity, stringPredicate: search, sortProperty, sortAscending: sortAscending)
    }
    
    func fetchEntities(entity: CoreDataEntities, stringPredicate predicates: String, _ sortProperty: EntityProperties, sortAscending: Bool = true) -> [NSManagedObject] {
        let request : NSFetchRequest = NSFetchRequest(entityName: entity.description())
        
        request.returnsObjectsAsFaults = false
                request.predicate = NSPredicate(format: predicates)
        
        var error: NSError? = nil
        
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: sortProperty.description(), ascending: sortAscending)
        request.sortDescriptors = [sortDescriptor]
        
        return self.executeFetchRequest(request, error: &error) as [NSManagedObject]
    }
    
    func fetchEntitiesGeneral (entity : CoreDataEntities, sortProperty : EntityProperties, sortAscending: Bool = true) -> [NSManagedObject]? {
        
        let entityName = entity.description()
        //let propertyName = property.description()
        
        let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: sortProperty.description(), ascending: true)
        request.sortDescriptors = [sortDescriptor]
        var error: NSError? = nil
        var matches: NSArray = self.executeFetchRequest(request, error: &error)
        
        if matches.count > 0 {
            return matches as [NSManagedObject]
        }
        else {
            return nil
        }
    }

    func fetchCardByKanji(kanji: String) -> Card? {
        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji)
        
        return value as Card?
    }

    func fetchCardByIndex(index: NSNumber) -> Card? {
        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.index, index)
        
        if value as? Card {
            return value as? Card
        }
        
        return nil
    }
}