import Foundation
import UIKit
import CoreData

enum CoreDataEntities {
    case Card
    func description() -> String {
        switch self {
        case .Card:
            return "Card"
        }
    }
}

class CustomUIViewController : UIViewController
{
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    func loadContext ()
    {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
        
        loadContext()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}