import UIKit
import CoreData

extension NSMutableAttributedString {
    func addBreak(size: CGFloat)
    {
        if(size > 0)
        {
            self.addAttributedText(" ", NSFontAttributeName, UIFont(name: "Helvetica", size: size));
        }
    }
    
    func addAttributedText(var text: String, _ attributeName: String, _ object: AnyObject, breakLine: Bool = true, processAttributes: Bool = false, removeSpaces: Bool = false)
    {
        var bolds: NSRange[] = []
        
        if removeSpaces
        {
            text = text.removeFromString(text, " ")
        }
        
        if breakLine
        {
            text += "\n"
        }
        
        if processAttributes
        {
            
            text = text.removeTagsFromString(text)
            
            //            {
            //                var broken = sentence.componentsSeparatedByString("")
            //
            //            var spanSizeOpen = text.componentsSeparatedByString("<span style=\"font-size:20px\">")
            //            text = ""
            //
            //            for item in spanSizeOpen
            //            {
            //                var itemSplit = item.componentsSeparatedByString("</span>")
            //
            //                for var i = 0; i < countElements(itemSplit); i++
            //                {
            //                    var previousSize = countElements(text)
            //                    text += itemSplit[i]
            //
            //                    if i == 0
            //                    {
            //                        var color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            //
            //                        println(self.mutableString)
            //
            //                        var range: NSRange = NSMakeRange(self.mutableString.length, 2)
            //                        self.addAttribute(NSBackgroundColorAttributeName, value: color, range: range)
            //                    }
            //                }
            //            }
        }
        
        var existingLength: Int = self.mutableString.length
        var range: NSRange = NSMakeRange(existingLength, countElements(text))
        self.mutableString.appendString(text)
        
        self.addAttribute(attributeName, value: object, range: range)
    }
}
//
//// FETCH REQUESTS
//

func fetchCardsGeneral (entity : CoreDataEntities,
    property : CardProperties,
    context : NSManagedObjectContext) -> AnyObject[]?{
        
        let entityName = entity.description()
        let propertyName = property.description()
        
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
    context : NSManagedObjectContext) -> AnyObject[]? {
        
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
    var value : AnyObject? = fetchCard(CardProperties.kanji, kanji, context)//self.managedObjectContext)
    
    return value as Card
}

func fetchCardByIndex(index: NSNumber, context : NSManagedObjectContext) -> Card
{
    var value : AnyObject? = fetchCard(CardProperties.index, index, context)//self.managedObjectContext)
    
    return value as Card
}

func fetchCard (property : CardProperties,
    value : NSObject,
    context : NSManagedObjectContext) -> AnyObject? {
        
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