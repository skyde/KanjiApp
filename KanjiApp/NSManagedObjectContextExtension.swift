import UIKit
import CoreData

extension NSManagedObjectContext
{
    func fetchEntity<T: NSManagedObject> (entity: CoreDataEntities, _ property:EntityProperties? = nil, _ value:CVarArgType = "", var createIfNil: Bool = false) -> T? {
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
        
        var value = T(entity: entityDescription, insertIntoManagedObjectContext: self)
        
        //            switch property {
        //            case .kanji:
        //                card.kanji = value
        //            default:
        //                return card
        //            }
        return value
        //        }
        //return nil
    }
    func fetchEntities(
        entity: CoreDataEntities,
        _ predicates: [(EntityProperties, AnyObject)],
        _ sortProperty: EntityProperties,
        sortAscending: Bool = true) -> [NSManagedObject] {
        var arguments: [AnyObject] = []
        var search = ""
        var and = ""
        
        for predicate in predicates
        {
            arguments.append(predicate.1)
            
            search += and
            search += "(\(predicate.0.description())==%@)"
            
            and = " AND "
        }
        
        return fetchEntities(entity, rawPredicate: (search, arguments), sortProperty, sortAscending: sortAscending)
    }
    
    func fetchEntities(
        entity: CoreDataEntities,
        rawPredicate predicate: (format: String, arguments: [AnyObject]),
        _ sortProperty: EntityProperties,
        sortAscending: Bool = true) -> [NSManagedObject] {
            
        let request : NSFetchRequest = NSFetchRequest(entityName: entity.description())
            
//            println(predicate.format)
//            println(predicate.arguments)
        
        request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: predicate.format, argumentArray: predicate.arguments)
        
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

    // Helpers
    
    func fetchCardByKanji(kanji: String) -> Card? {
        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji)
        
        return value as Card?
    }
    
    func fetchCardByIndex(index: NSNumber) -> Card? {
        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.index, index)
        
        if value as? Card != nil {
            return value as? Card
        }
        
        return nil
    }
    
//    func fetchCardByIndex(index: NSNumber) -> Card? {
//        var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.index, index)
//        
//        if value as? Card {
//            return value as? Card
//        }
//        
//        return nil
    //    }
    
    /// ahead amount should be in seconds
    func fetchCardsStudyAhead(var aheadAmount: Double) -> [Card] {
        
        var predicate = "(enabled==%@) AND (suspended==%@) AND (known==%@) AND (dueTime<%@)"
        var values: [AnyObject] = [true, false, false, Globals.secondsSince1970 + aheadAmount]
        
        return fetchEntities(.Card, rawPredicate: (predicate, values), CardProperties.dueTime, sortAscending: true) as [Card]
    }
    
    func fetchCardsDue() -> [Card] {
        
        var predicate = "(enabled==%@) AND (suspended==%@) AND (known==%@) AND (dueTime<%@)"
        var values: [AnyObject] = [true, false, false, Globals.secondsSince1970]
        
        return fetchEntities(.Card, rawPredicate: (predicate, values), CardProperties.dueTime, sortAscending: true) as [Card]
    }
    
    func fetchCardsActive() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.enabled, true), (CardProperties.suspended, false), (CardProperties.known, false)], CardProperties.interval, sortAscending: true) as [Card]
    }
    
    func fetchCardsWillStudy() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true) as [Card]
    }
    func fetchCardsKnown() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.suspended, false), (CardProperties.known, true)], CardProperties.interval, sortAscending: true) as [Card]
    }
    
    func fetchCardsJLPT4Suspended() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.jlptLevel, 4), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true) as [Card]
    }
    
    func fetchCardsJLPT3Suspended() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.jlptLevel, 3), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true) as [Card]
    }
    
    func fetchCardsJLPT2Suspended() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.jlptLevel, 2), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true) as [Card]
    }
    
    func fetchCardsJLPT1Suspended() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.jlptLevel, 1), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true) as [Card]
    }
    
    func fetchCardsAllWordsSuspended() -> [Card] {
        return fetchEntities(.Card, [(CardProperties.suspended, true)], CardProperties.interval, sortAscending: true) as [Card]
    }
}