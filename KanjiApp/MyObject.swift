import UIKit
import CoreData

enum CoreDataEntities {
    case MyObject
    func description() -> String {
        switch self {
        case .MyObject:
            return "MyObject"
        }
    }
}

enum MyObjectPropertyList {
    case name
    func description() -> String {
        switch self {
        case .name:
            return "name"
        }
    }
}

@objc(MyObject)
class MyObject: NSManagedObject {
    
    @NSManaged var name: String
    
    //
    //// CREATE CLASS OBJECT
    //
    
    class func createMyObject (propertyName:MyObjectPropertyList, value:String, context: NSManagedObjectContext) -> MyObject? {
        if !value.isEmpty {
            let propertyType = propertyName.description()
            
            let entityName = "MyObject"
            let request : NSFetchRequest = NSFetchRequest(entityName: entityName)
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "\(propertyType) = %@", value)
            var error: NSError? = nil
            var matches: NSArray = context.executeFetchRequest(request, error: &error)
            
            if (matches.count > 1) {
                // handle error
                return matches[0] as? MyObject
            } else if matches.count ==  0 {
                let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
                var myObject : MyObject = MyObject(entity: entityDescription, insertIntoManagedObjectContext: context)
                myObject.name = value
                return myObject
            }
            else {
                println(matches[0])
                return matches[0] as? MyObject
            }
        }
        return nil
    }
}

//
//// FETCH REQUESTS
//

func myGeneralFetchRequest (entity : CoreDataEntities,
    property : MyObjectPropertyList,
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
    property : MyObjectPropertyList,
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
        for myobject : AnyObject in myarray {
            var anObject = myobject as MyObject
            var thename = anObject.name
            println(thename)
        }
    }
    else {
        println("empty fetch")
    }
}