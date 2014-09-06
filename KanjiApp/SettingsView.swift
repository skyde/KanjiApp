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
            value += "\(card.index) \(card.embeddedData.answersKnown) \(card.embeddedData.answersNormal) \(card.embeddedData.answersHard) \(card.embeddedData.answersForgot) \(card.interval) \(card.dueTime) \(card.enabled) \(card.suspended) \(card.known)\n"
        }
        //        value = "test value"
//        println(allCards.count)
        
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
//        
        let fileName = "ListsBackup.kanji"
//                var path = (UIApplication.sharedApplication().delegate! as AppDelegate).applicationDocumentsDirectory
//        
//        path = path.URLByAppendingPathComponent(fileName)
//        var pathString = NSString(format:"%@", [path])
//
//        var error: NSErrorPointer = nil
//        value.writeToFile(pathString, atomically: false, encoding: NSUTF8StringEncoding, error: error)
        
        //        var alert = UIAlertView(title: "Exported", message: "exported file", delegate: nil, cancelButtonTitle: nil)
        //        alert.show()
        var emailTitle = "Export Lists"
        var messageBody = "This is a backup of user data for the app Kanji"
        var toRecipents = []
        var mc: MFMailComposeViewController = MFMailComposeViewController()
        
//        println("Mail Text")
//        println(pathString)
//        println(value)
        
        var data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)//NSData(contentsOfFile: pathString)////
        //MFMailComposeViewControllerDelegate
//        println("data)
//        println(data)
        
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        //text/plain
        //
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
    }
}