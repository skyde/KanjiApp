import Foundation
import UIKit
import CoreData

class CustomUIViewController : UIViewController
{
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    func loadContext ()
    {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    func isNavigationBarHidden() -> Bool
    {
        return false
    }
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
        
        loadContext()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.translucent = true
        self.navigationController.view.backgroundColor = UIColor.clearColor()
        
        navigationController.navigationBarHidden = isNavigationBarHidden()
    }
    
    func saveContext (context: NSManagedObjectContext) {
        var error: NSError? = nil
        context.save(&error)
    }
}