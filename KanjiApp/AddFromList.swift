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
    
//    @IBOutlet var addAmountPicker: UIPickerView
    
    var settings: Settings {
    get {
        return managedObjectContext.fetchEntity(CoreDataEntities.Settings, SettingsProperties.userName, "default")! as Settings
    }
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        var settings = managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default")! as Settings
        
        settings.userName = "default"
        
//        addAmountPicker.
        
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
        
        jlptLevel.selectedSegmentIndex = settings.jlptLevel.integerValue
        isOnlyKanji.on = settings.onlyStudyKanji.boolValue
        addAmount.text = settings.cardAddAmount.stringValue
    }
    
    @IBAction func onJlptLevelChanged(sender : AnyObject)
    {
        settings.jlptLevel = jlptLevel.selectedSegmentIndex
        
        saveContext()
    }
    
    @IBAction func isOnlyKanjiChanged(sender : AnyObject)
    {
        settings.onlyStudyKanji = isOnlyKanji.on
        
        saveContext()
    }
    
    @IBAction func addAmountChanged(sender : AnyObject)
    {
        var amount = addAmount.text.toInt()
        
        println(amount)
        
        if var castAmount = amount
        {
            settings.cardAddAmount = castAmount
        }
        else
        {
            addAmount.text = settings.cardAddAmount.stringValue
        }
    }
    
//    func fetchSettings() -> Settings
//    {
//    }
//    @IBOutlet var onOnlyKanjiInteract : UISwitch
//    @IBOutlet var onAddAmountInteract : UITextField
//    @IBOutlet var onAddButtonInteract : UIButton
}
