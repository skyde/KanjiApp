import Foundation
import UIKit
import CoreData
import MessageUI

class CustomUIViewController : UIViewController, MFMailComposeViewControllerDelegate {
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
        if isGameView {
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
    
    func exportUserList() -> String {
        var value = ""
        
        //println(managedObjectContext.fetchCardsAllWords().count)
        
        //        index
        //        answersKnown
        //        answersNormal
        //        answersHard
        //        answersForgot
        //        interval
        //        dueTime
        //        enabled
        //        suspended
        //        known
        
        for card in managedObjectContext.fetchCardsAllUser() {
            value += "\(card.index) \(card.answersKnown) \(card.answersNormal) \(card.answersHard) \(card.answersForgot) \(card.interval) \(card.dueTime) \(card.enabled) \(card.suspended) \(card.known)\n"
        }
        mailText(value)
        
        return value
    }
    
    func mailText(value: String) {
//        [someText writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
//        
//        NSString *someText = "Here's to some awesome text.";
//        
//        NSError *error = nil;
//        
//        NSString *path = [NSString stringWithFormat:@"%@",[[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"someText.txt"] absoluteString]];
//        
//        //Write to the file
//        [someText writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
//        NSString *someText = "Here's to some awesome text.";

//        var path = (UIApplication.sharedApplication().delegate! as AppDelegate).applicationDocumentsDirectory
//        
        let fileName = "ListsBackup.kanji"
//        path = path.URLByAppendingPathComponent(fileName)
//        var pathString = NSString(format:"%@", [path])
//
//        var error: NSErrorPointer = nil
////        value.wri
//        value.writeToFile(pathString, atomically: true, encoding: NSUTF8StringEncoding, error: error)
        
//        var alert = UIAlertView(title: "Exported", message: "exported file", delegate: nil, cancelButtonTitle: nil)
        //        alert.show()
        var emailTitle = "Export Lists"
        var messageBody = "This is a backup of user data for the app Kanji"
        var toRecipents = []
        var mc: MFMailComposeViewController = MFMailComposeViewController()
        
        var data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)//NSData(contentsOfFile: pathString)
        
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        mc.addAttachmentData(data, mimeType: "com.binarypipeline.kanji", fileName: fileName)
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func importUserList(source: String) {
        for card in managedObjectContext.fetchCardsAllWords() {
            card.answersKnown = 0
            card.answersNormal = 0
            card.answersHard = 0
            card.answersForgot = 0
            card.interval = 0
            card.dueTime = 0
            card.enabled = false
            card.suspended = true
            card.known = false
        }
        
        var values = source.componentsSeparatedByString("\n")
        for value in values {
            let splits = value.componentsSeparatedByString(" ")
            
            let index = splits[0].toInt()
            let answersKnown = splits[1].toInt()
            let answersNormal = splits[2].toInt()
            let answersHard = splits[3].toInt()
            let answersForgot = splits[4].toInt()
            let interval = splits[5].toInt()
            let dueTime = (splits[6] as NSString).doubleValue
            let enabled = splits[7].toInt()
            let suspended = splits[8].toInt()
            let known = splits[9].toInt()
            
            if let card = managedObjectContext.fetchCardByIndex(index!) {
                card.answersKnown = answersKnown!
                card.answersNormal = answersNormal!
                card.answersHard = answersForgot!
                card.answersForgot = answersKnown!
                card.interval = interval!
                card.dueTime = dueTime
                card.enabled = enabled!
                card.suspended = suspended!
                card.known = known!
            }
        }
        
        saveContext()
    }
}