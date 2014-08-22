import Foundation
import UIKit
import CoreData
import MessageUI

class SettingsView: CustomUIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var volume: UISlider!
    
    @IBAction func onVolumeChanged(sender: AnyObject) {
        settings.volume = volume.value
        saveContext()
    }
    
    @IBAction func onBackupTap(sender: AnyObject) {
//        println("backup")
//        managedObjectContext.
        self.exportUserList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        volume.value = settings.volume.floatValue
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
        var allCards = managedObjectContext.fetchCardsAllUser()
        
        for card in allCards {
            value += "\(card.index) \(card.answersKnown) \(card.answersNormal) \(card.answersHard) \(card.answersForgot) \(card.interval) \(card.dueTime) \(card.enabled) \(card.suspended) \(card.known)\n"
        }
        //        value = "test value"
        println(allCards.count)
        
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
        //        path = path.URLByAppendingPathComponent(fileName)
        //        var pathString = NSString(format:"%@", [path])
        //
        //        var error: NSErrorPointer = nil
        ////        value.wri
        //        value.writeToFile(pathString, atomically: true, encoding: NSUTF8StringEncoding, error: error)
        
        //        var alert = UIAlertView(title: "Exported", message: "exported file", delegate: nil, cancelButtonTitle: nil)
        //        alert.show()
        let fileName = "ListsBackup.kanji"
        var emailTitle = "Export Lists"
        var messageBody = "This is a backup of user data for the app Kanji"
        var toRecipents = []
        var mc: MFMailComposeViewController = MFMailComposeViewController()
        
        println("Mail Text")
//        println(value)
        
        var data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)//NSData(contentsOfFile: pathString)
        //MFMailComposeViewControllerDelegate
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        //text/plain
        mc.addAttachmentData(data, mimeType: "com.binarypipeline.kanji", fileName: fileName)
        //self.addChildViewController(mc)
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
//        switch result.value {
//        case MFMailComposeResultCancelled.value:
//            println("Mail cancelled")
//        case MFMailComposeResultSaved.value:
//            println("Mail saved")
//        case MFMailComposeResultSent.value:
//            println("Mail sent")
//        case MFMailComposeResultFailed.value:
//            println("Mail sent failure: %@", [error.localizedDescription])
//        default:
//            break
        //        }
//        println("mailComposeController")
//        println(self.navigationController)
//        
//        self.navigationController?.popViewControllerAnimated(true)
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.dis
        //Globals.notificationTransitionToView.postNotification(.Settings)
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