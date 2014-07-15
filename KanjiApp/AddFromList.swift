import Foundation
import UIKit
import CoreData

class AddFromList: CustomUIViewController
{
    //@IBOutlet var outputText: UITextView
    @IBOutlet var jlptLevel : UISegmentedControl
    @IBOutlet var isOnlyKanji : UISwitch
    @IBOutlet var addAmount : UITextField
    @IBOutlet var addButton : UIButton
    
    var settings: Settings {
    get {
//        println(managedObjectContext.fetchEntitiesGeneral(CoreDataEntities.Settings, sortProperty: SettingsProperties.userName))
        
        return managedObjectContext.fetchEntity(CoreDataEntities.Settings, SettingsProperties.userName, "default")! as Settings
//        return
    }
    }
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
        
        var settings = managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default")! as Settings
        
        settings.userName = "default"
        
        saveContext()
    }
//        super.init(coder: aDecoder)
//        
////        if let settings = fetchCardsGeneral(CoreDataEntities.Settings, self.managedObjectContext, SettingsProperties.jlptLevel.description()) {
////            
////            //settings[0].
////        }
////        
////        saveContext(self.managedObjectContext)
//    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        println(managedObjectContext.fetchEntitiesGeneral(CoreDataEntities.Settings, sortProperty: SettingsProperties.userName)?.count)
//
//        //var settings = fetchSettings()
//        
//        println("settings.jlptLevel = \(settings.jlptLevel)")
//        println("addAmount = \(addAmount)")
//        
        jlptLevel.selectedSegmentIndex = settings.jlptLevel.integerValue
    }
    
//    override func saveContext(context: NSManagedObjectContext)
//    {
//        
//        
//        super.saveContext(context)
//    }
//    @IBOutlet var onJlptLevelInteract : UISegmentedControl
    @IBAction func onJlptLevelChanged(sender : AnyObject)
    {
        settings.jlptLevel = jlptLevel.selectedSegmentIndex
        
        println(settings.jlptLevel)
        
        saveContext()
    }
    
    @IBAction func isOnlyKanjiChanged(sender : AnyObject)
    {
    }
    
    @IBAction func addAmountChanged(sender : AnyObject)
    {
    }
    
//    func fetchSettings() -> Settings
//    {
//    }
//    @IBOutlet var onOnlyKanjiInteract : UISwitch
//    @IBOutlet var onAddAmountInteract : UITextField
//    @IBOutlet var onAddButtonInteract : UIButton
}
