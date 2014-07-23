import Foundation
import UIKit
import CoreData

class CustomUIViewController : UIViewController {
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    var settings: Settings {
    get {
        return managedObjectContext.fetchEntity(CoreDataEntities.Settings, SettingsProperties.userName, "default")! as Settings
    }
    }
    
    func loadContext () {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    func isNavigationBarHidden() -> Bool {
        return false
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        loadContext()
        
        var settings = managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default", createIfNil: true)! as Settings
        
        settings.userName = "default"
        
        if settings.cardAddAmount == 0
        {
            settings.cardAddAmount = 5
            settings.onlyStudyKanji = true
            settings.volume = 0.5
        }
        
        saveContext()
    }
    
//    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//        initSelf()
//    }
//    
//    func initSelf() {
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navigationController.navigationBar.shadowImage = UIImage()
//        navigationController.navigationBar.translucent = true
//        navigationController.view.backgroundColor = UIColor.clearColor()
//        
//        navigationController.navigationBarHidden = isNavigationBarHidden()
    }
    
    func saveContext (_ context: NSManagedObjectContext? = nil) {
        if var c = context {
            var error: NSError? = nil
            c.save(&error)
        }
        else {
            var error: NSError? = nil
            self.managedObjectContext.save(&error)
        }
    }
}