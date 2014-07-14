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
        return NSManagedObject.createEntity(.Settings, self.managedObjectContext, property: SettingsProperties.userName, value: "default")! as Settings;
    }
    }
//    init(coder aDecoder: NSCoder!)
//    {
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
        
        //var settings = fetchSettings()
        
        println("settings.jlptLevel = \(settings.jlptLevel)")
        println("addAmount = \(addAmount)")
        
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
        
        println(jlptLevel.selectedSegmentIndex)
        
        saveContext(self.managedObjectContext)
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
