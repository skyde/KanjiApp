import Foundation
import UIKit
import CoreData

class AddFromList: CustomUIViewController {
    @IBOutlet var jlptLevel : UISegmentedControl
    @IBOutlet var isOnlyKanji : UISwitch
    @IBOutlet var addAmount : UITextField
    @IBOutlet var addButton : UIButton
    
//    init(coder aDecoder: NSCoder!) {
//        super.init(coder: aDecoder)
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jlptLevel.selectedSegmentIndex = settings.jlptLevel.integerValue
        isOnlyKanji.on = settings.onlyStudyKanji.boolValue
        addAmount.text = settings.cardAddAmount.stringValue
    }
    
    @IBAction func onAddTouch(sender: AnyObject) {
        println("button")
    }
    
    @IBAction func onJlptLevelChanged(sender : AnyObject) {
        var value = jlptLevel.selectedSegmentIndex
        
        settings.jlptLevel = 4 - value
        
        saveContext()
    }
    
    @IBAction func isOnlyKanjiChanged(sender : AnyObject) {
        settings.onlyStudyKanji = isOnlyKanji.on
        
        saveContext()
    }
    
    @IBAction func addAmountChanged(sender : AnyObject) {
        var amount = addAmount.text.toInt()
        
        println(amount)
        
        if var castAmount = amount {
            settings.cardAddAmount = castAmount
        }
        else {
            addAmount.text = settings.cardAddAmount.stringValue
        }
    }
}
