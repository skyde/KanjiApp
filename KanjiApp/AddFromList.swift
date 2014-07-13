import Foundation
import UIKit
import CoreData


class AddFromList: CustomUIViewController {
    
    //@IBOutlet var outputText: UITextView
    @IBOutlet var jlptLevel : UISegmentedControl
    @IBOutlet var isOnlyKanji : UISwitch
    @IBOutlet var addAmount : UITextField
    @IBOutlet var addButton : UIButton
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
//        if let settings = fetchCardsGeneral(CoreDataEntities.Settings, self.managedObjectContext, SettingsProperties.jlptLevel.description()) {
//            
//            //settings[0].
//        }
//        
//        saveContext(self.managedObjectContext)
    }
    
    override func saveContext(context: NSManagedObjectContext)
    {
        
        
        super.saveContext(context)
    }
//    @IBOutlet var onJlptLevelInteract : UISegmentedControl
    @IBAction func onJlptLevelChanged(sender : AnyObject) {
    }
    @IBAction func isOnlyKanjiChanged(sender : AnyObject) {
    }
    @IBAction func addAmountChanged(sender : AnyObject) {
    }
//    @IBOutlet var onOnlyKanjiInteract : UISwitch
//    @IBOutlet var onAddAmountInteract : UITextField
//    @IBOutlet var onAddButtonInteract : UIButton
}
