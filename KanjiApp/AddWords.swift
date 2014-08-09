import Foundation
import UIKit
import CoreData

class AddWords: CustomUIViewController {
//    @IBOutlet var jlptLevel : UISegmentedControl!
//    @IBOutlet var isOnlyKanji : UISwitch!
//    @IBOutlet var addAmount : UITextField!
//    @IBOutlet var addButton : UIButton!
//    
//    init(coder aDecoder: NSCoder!) {
//        super.init(coder: aDecoder)
//        
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Globals.notificationAddWordsFromList.addObserver(self, selector: "onAddWordsFromList")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if Globals.autoAddWordsFromList {
            onAddWordsFromList()
        }
    }
    
    func onAddWordsFromList() {
        
        var predicate: [(EntityProperties, AnyObject)] = []
        
        predicate += (CardProperties.enabled, false)
        
        switch Globals.notificationAddWordsFromList.value {
        case .AllWords:
            break;
        case .Jlpt4:
            predicate += (CardProperties.jlptLevel, "4")
        case .Jlpt3:
            predicate += (CardProperties.jlptLevel, "3")
        case .Jlpt2:
            predicate += (CardProperties.jlptLevel, "2")
        case .Jlpt1:
            predicate += (CardProperties.jlptLevel, "1")
        case .MyWords:
            predicate += (CardProperties.suspended, false)
        default:
            break;
        }
        
        let cards = managedObjectContext.fetchEntities(.Card, predicate, CardProperties.index, sortAscending: true)
        var addCards: [NSNumber] = []
        
        var added = 0
        
        for card in cards {
            if let card = card as? Card {
                var onlyStudyKanji = settings.onlyStudyKanji.boolValue
                
                if !onlyStudyKanji || (onlyStudyKanji && card.kanji.isPrimarilyKanji()) {
                    added++
                    card.enabled = true
                    card.suspended = false
                    addCards += card.index
                }
                
                if added >= settings.cardAddAmount.integerValue {
                    break
                }
            }
        }
        //managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, true), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
        //        items =
//        println("cardAddAmount \(settings.cardAddAmount.integerValue)")
//        println(addCards.count)
//        println(addCards)
        
//        Globals.viewCards = //.map { ($0 as Card).index }
        Globals.autoAddWordsFromList = false
        Globals.notificationTransitionToView.postNotification(.Lists(title: "Add Words", cards: addCards))
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
////        jlptLevel.selectedSegmentIndex = 4 - settings.jlptLevel.integerValue
////        isOnlyKanji.on = settings.onlyStudyKanji.boolValue
////        addAmount.text = settings.cardAddAmount.stringValue
//    }
    
//    @IBAction func onAddTouch(sender: AnyObject) {
////        self.navigationController.popToRootViewControllerAnimated(true)
////        self.performSegueWithIdentifier("GameMode", sender: self)
////        transitionToView(.GameMode)
//    }
    
//    @IBAction func onJlptLevelChanged(sender : AnyObject) {
//        var value = jlptLevel.selectedSegmentIndex
//        
//        settings.jlptLevel = 4 - value
//        
//        saveContext()
//    }
//    
//    @IBAction func isOnlyKanjiChanged(sender : AnyObject) {
//        settings.onlyStudyKanji = isOnlyKanji.on
//        
//        saveContext()
//    }
//    
//    @IBAction func addAmountChanged(sender : AnyObject) {
//        var amount = addAmount.text.toInt()
//        
//        if var amount = amount {
//            if amount == 0 {
//                amount = 1
//                addAmount.text = "\(1)"
//            }
//            
//            settings.cardAddAmount = amount
//        }
//        else if addAmount.text != "" {
//            addAmount.text = settings.cardAddAmount.stringValue
//        }
//    }
}
