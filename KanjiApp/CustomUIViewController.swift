import Foundation
import UIKit
import CoreData

class CustomUIViewController : UIViewController {
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    var settings: Settings {
    get {
        return (managedObjectContext.fetchEntity(CoreDataEntities.Settings, SettingsProperties.userName, "default") as Settings?)!
    }
    }
    
    func loadContext () {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
//    var isNavigationBarHidden: Bool {
//    get {
//        return false
//    }
//    }
    
    var isGameView: Bool {
    get {
        return true
    }
    }
    
    var alwaysReceiveNotifications: Bool {
    get {
        return false
    }
    }
//    
//    func receiveTransitionToViewNotifications() -> Bool {
//        return true
//    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        loadContext()
        
//        println(managedObjectContext)
        
        var settings = (managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default", createIfNil: true) as Settings?)!
        
        settings.userName = "default"
        
        if !settings.generatedCards.boolValue {
            settings.generatedCards = true
            settings.cardAddAmount = 5
            settings.onlyStudyKanji = true
            settings.volume = 0.5
            settings.readerText = ""
            
            createDatabase("AllCards copy")
        }
        
        saveContext()
    }
    
    override func viewWillAppear(animated: Bool) {
        if !alwaysReceiveNotifications {
            addNotifications()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if !alwaysReceiveNotifications {
            removeNotifications()
        }
    }
    
    func addNotifications() {
        Globals.notificationTransitionToView.addObserver(self, selector: "onTransitionToView")
    }
    
    func removeNotifications() {
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
                
                var dataDesc = NSEntityDescription.entityForName("CardData", inManagedObjectContext: managedObjectContext)
                
                card.embeddedData = CardData(entity: dataDesc, insertIntoManagedObjectContext: managedObjectContext)
                
                card.index = index
                card.hiragana = items[2]
                card.embeddedData.definition = items[3]
                card.embeddedData.exampleEnglish = items[4]
                card.embeddedData.exampleJapanese = items[5]
                card.embeddedData.soundWord = items[6]
                card.embeddedData.soundDefinition = items[7]
                card.embeddedData.definitionOther = items[8]
                card.usageAmount = usageAmount
                card.jlptLevel = jlptLevel
                card.embeddedData.pitchAccentText = items[11]
                card.embeddedData.pitchAccent = pitchAccent
                card.embeddedData.otherExampleSentences = items[13]
                card.answersKnown = 0
                card.answersNormal = 0
                card.answersHard = 0
                card.answersForgot = 0
                card.interval = 0
                card.dueTime = 0
                card.enabled = false
                card.suspended = true
                card.known = false
                
                values.append(card)
            }
        }
        
        
        saveContext()
    }
    
    func onTransitionToView() {
//        let targetView = Globals.notificationTransitionToView.value
        
        if isGameView {
//            println("pop to root view \(self)")
            self.navigationController?.popToRootViewControllerAnimated(false)
        }
    }
    
//    func transitionToView(targetView: View) {
////        Globals.targetView = target
//        NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationTransitionToView, object: Container(targetView))
//    }
    
    
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
        
        if alwaysReceiveNotifications {
            addNotifications()
        }
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