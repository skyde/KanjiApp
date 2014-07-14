import UIKit
import CoreData

func fetchCardsGeneral (entity : CoreDataEntities, context : NSManagedObjectContext, sortProperty : String, sortAscending: Bool = true) -> [AnyObject]?{
    
    let entityName = entity.description()
    //let propertyName = property.description()
    
    let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
    request.returnsObjectsAsFaults = false
    let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: CardProperties.interval.description(), ascending: true)
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

func fetchCardByKanji(kanji: String, context : NSManagedObjectContext) -> Card
{
    var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.kanji.description(), kanji, context)//self.managedObjectContext)
    
    return value as Card
}

func fetchCardByIndex(index: NSNumber, context : NSManagedObjectContext) -> Card
{
    var value : AnyObject? = fetchEntity(CoreDataEntities.Card, CardProperties.index.description(), index, context)//self.managedObjectContext)
    
    return value as Card
}

func fetchEntity (entity : CoreDataEntities, propertyName : String, value : NSObject, context : NSManagedObjectContext) -> AnyObject? {
    
    //let entity = CoreDataEntities.Card
    let entityName = entity.description()
    //        let propertyName = property.description()
    
    let request :NSFetchRequest = NSFetchRequest(entityName: entityName)
    request.returnsObjectsAsFaults = false
    request.predicate = NSPredicate(format: "\(propertyName) = %@", value)
    let sortDescriptor :NSSortDescriptor = NSSortDescriptor(key: propertyName, ascending: true)
    request.sortDescriptors = [sortDescriptor]
    var error: NSError? = nil
    var matches: NSArray = context.executeFetchRequest(request, error: &error)
    
    if matches.count > 0 {
        return matches[0]
    }
    else {
        return nil
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