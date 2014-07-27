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
    
    func isGameView() -> Bool {
        return true
    }
    
    func receiveTransitionToViewNotifications() -> Bool {
        return true
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        loadContext()
        
        var settings = managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default", createIfNil: true)! as Settings
        
        settings.userName = "default"
        
        if !settings.generatedCards.boolValue {
            settings.generatedCards = true
            settings.cardAddAmount = 5
            settings.onlyStudyKanji = true
            settings.volume = 0.5
            
            createDatabase("AllCards copy")
        }
        
        saveContext()
    }
    
    override func viewWillAppear(animated: Bool) {
        if receiveTransitionToViewNotifications() {
            addToNotifications()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if receiveTransitionToViewNotifications() {
            removeFromNotifications()
        }
    }
    
    func addToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTransitionToView", name: transitionToViewNotification, object: nil)
    }
    
    func removeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func createDatabase(filename: String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        
        var values: [Card] = []
        
        if let content = possibleContent {
            var deck = content.componentsSeparatedByString("\n")
            for deckItem in deck {
                var items = deckItem.componentsSeparatedByString("\t")
                
                var index: Int = items[1].toInt()!
                var pitchAccent = 0
                if var p = items[12].toInt() {
                    pitchAccent = p
                }
                
                var usageAmount = 0
                if var u = items[9].toInt() {
                    usageAmount = u
                }
                
                var jlptLevel = 0
                if var j = items[10].toInt() {
                    jlptLevel = j
                }
                
                let kanji = items[0]
                
                var card = managedObjectContext.fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji, createIfNil: true)! as Card
                
                card.kanji = kanji
                
                card.index = index
                card.hiragana = items[2]
                card.definition = items[3]
                card.exampleEnglish = items[4]
                card.exampleJapanese = items[5]
                card.soundWord = items[6]
                card.soundDefinition = items[7]
                card.definitionOther = items[8]
                card.usageAmount = usageAmount
                card.jlptLevel = jlptLevel
                card.pitchAccentText = items[11]
                card.pitchAccent = pitchAccent
                card.otherExampleSentences = items[13]
                card.answersKnown = 0
                card.answersNormal = 0
                card.answersHard = 0
                card.answersForgot = 0
                card.interval = 0
                card.dueTime = 0
                card.suspended = true
                
                values += card
            }
        }
        
        saveContext()
    }
    
    func onTransitionToView() {
        if isGameView() {
            transitionToView(targetView)
        }
    }
    
    func transitionToView(target: View) {
        targetView = target
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    
//    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//        initSelf()
//    }
//    
//    func initSelf() {
//    }
    
//     override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
//        println("t")
//    }
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
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