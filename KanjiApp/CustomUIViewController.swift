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
    
    var isGameView: Bool {
        get {
            return true
        }
    }
    
    var sidebarEnabled: Bool {
        get {
            return true
        }
    }
    
    var alwaysReceiveNotifications: Bool {
    get {
        return false
    }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadContext()
        
        var settings = (managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default", createIfNil: true) as Settings?)!
        
        settings.userName = "default"
        
        if !settings.generatedCards.boolValue {
            createDatabaseV2("jdict")
            createDatabase("AllCards copy")
            
            settings.generatedCards = true
            settings.readerText = ""
        }
        
        saveContext()
    }
    
    var notificationsActive = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        println("viewWillAppear \(self)")
        if !alwaysReceiveNotifications && !notificationsActive {
            addNotifications()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !alwaysReceiveNotifications && !notificationsActive {
            addNotifications()
        }
        
        Globals.notificationGameViewDidAppear.postNotification(self)
//
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !alwaysReceiveNotifications && notificationsActive {
            removeNotifications()
        }
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        if !alwaysReceiveNotifications && notificationsActive {
            removeNotifications()
        }
    }
    
    func addNotifications() {
        notificationsActive = true
        
        Globals.notificationTransitionToView.addObserver(self, selector: "onTransitionToView")
    }
    
    func removeNotifications() {
        notificationsActive = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            return urls[urls.endIndex-1] as NSURL
    }
    
    let validChars = NSCharacterSet(range: NSRange(location: 32, length: 127))
    func isJapaneseCharacter(var item: String) -> Bool? {
        
        if  item == "[" ||
            item == "]" ||
            item == "" {
            return nil
        }
        
        if item == " " ||
            item == "   " ||
            item == "　" ||
            item == "-" ||
            item == "(" ||
            item == ")" {
            return nil
        }
        
        if  item == "0" ||
            item == "1" ||
            item == "2" ||
            item == "3" ||
            item == "4" ||
            item == "5" ||
            item == "6" ||
            item == "7" ||
            item == "8" ||
            item == "9"
        {
            return false
        }
        
        var splitOnAlphabet = item.componentsSeparatedByCharactersInSet(validChars)[0]
//        
//        println("splitOnAlphabet.count \(countElements(splitOnAlphabet))");
//        println("splitOnAlphabet \(splitOnAlphabet)");
        
        if countElements(splitOnAlphabet) == 0 {
            return false
        }
        
        return true
    }
    
    func createDatabaseV2(filename: String) {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        var values: [Card] = []
        
        if let content = possibleContent {
            var deck = content.componentsSeparatedByString("\n")
            var i = 100000;
            for deckItem in deck {
                var items = deckItem.componentsSeparatedByString("\t")
                
                if(items.count < 4)
                {
                    continue
                }
                
//                var index: Int = items[1].toInt()!
//                var pitchAccent = 0
//                if var p = items[12].toInt() {
//                    pitchAccent = p
//                }
                
//                var usageAmount = 0
//                if var u = items[9].toInt() {
//                    usageAmount = u
//                }
//                
//                var jlptLevel = 0
//                if var j = items[10].toInt() {
//                    jlptLevel = j
//                }
                
                let kanji = items[0]
                
//                println(kanji)
                
                var card = managedObjectContext.fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji, createIfNil: true)! as Card
                
                card.kanji = kanji
                
                var dataDesc = NSEntityDescription.entityForName("CardData", inManagedObjectContext: managedObjectContext)
                
                card.embeddedData = CardData(entity: dataDesc!, insertIntoManagedObjectContext: managedObjectContext)
                
                card.index = i
                card.hiragana = items[1]
                card.definition = items[2]
                
                card.embeddedData.exampleEnglish = ""
                card.embeddedData.exampleJapanese = ""
                
                var otherExamples = items[3]
                
                card.embeddedData.otherExampleSentences = otherExamples
                
                if(otherExamples != "")
                {
                    var split = otherExamples.componentsSeparatedByString("<br />")
                    
                    var j = ""
                    var e = ""
                    
                    if(split.count > 0 && split[0] != "" && split[0] != " ")
                    {
                        var first = split[0]
//                        println("first \(first)")
                        
                        for var i = 0; i < countElements(first); i++
                        {
                            var t = first[i..<i+1]
//                            println("t = \(t)")
                            var test = isJapaneseCharacter(t)
                            if test == true || test == nil
                            {
                                j += t
                            }
                            else
                            {
//                                println("BREAK")
                                break
                            }
                        }
                        
                        e = first[countElements(j)..<countElements(first)]
                        
//                        println("e = \(e)")
//                        println("j = \(j)")
                        card.embeddedData.exampleEnglish = e
                        card.embeddedData.exampleJapanese = j
                        card.embeddedData.otherExampleSentences = otherExamples[countElements(first)..<countElements(otherExamples)]
//                        println("END WORD")
                    }
                    
                }
                
                card.embeddedData.soundWord = ""
                card.embeddedData.soundDefinition = ""
                card.embeddedData.definitionOther = ""
                card.usageAmount = 0
                card.jlptLevel = 0
                card.embeddedData.pitchAccentText = ""
                card.embeddedData.pitchAccent = 0
                
                card.embeddedData.answersKnown = 0
                card.embeddedData.answersNormal = 0
                card.embeddedData.answersHard = 0
                card.embeddedData.answersForgot = 0
                card.interval = 0
                card.dueTime = 0
                card.enabled = false
                card.suspended = true
                card.known = false
                card.isKanji = kanji.isPrimarilyKanji()
                
                values.append(card)
                
                i++
            }
        }
        
        
        saveContext()
    }
    
    func createDatabase(filename: String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
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
                
                card.embeddedData = CardData(entity: dataDesc!, insertIntoManagedObjectContext: managedObjectContext)
                
                card.index = index
                card.hiragana = items[2]
                card.definition = items[3]
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
                card.embeddedData.answersKnown = 0
                card.embeddedData.answersNormal = 0
                card.embeddedData.answersHard = 0
                card.embeddedData.answersForgot = 0
                card.interval = 0
                card.dueTime = 0
                card.enabled = false
                card.suspended = true
                card.known = false
                card.isKanji = kanji.isPrimarilyKanji()
                
                values.append(card)
            }
        }
        
        
        saveContext()
    }
    
    func onTransitionToView() {
        if isGameView {
//            println("transition to root \(Globals.notificationTransitionToView.value.description())")
            self.navigationController?.popToRootViewControllerAnimated(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if alwaysReceiveNotifications {
            addNotifications()
        }
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