import Foundation
import UIKit

class AddWordsList: UITableViewController, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
    
    var myWordsEnabled = false
    
    override func viewDidAppear(animated: Bool) {
        
//        table.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0
//            ), animated: false, scrollPosition: .Top)
        
        myWordsEnabled = RootContainer.instance.managedObjectContext.fetchCardsWillStudy().count > 0
        
        table.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))?.textLabel?.enabled = myWordsEnabled
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        var sourceList: WordList?
        
        switch indexPath.row {
        case 0:
            if myWordsEnabled {
                sourceList = .MyWords
            }
        case 1:
            sourceList = .Jlpt4
        case 2:
            sourceList = .Jlpt3
        case 3:
            sourceList = .Jlpt2
        case 4:
            sourceList = .Jlpt1
        case 5:
            sourceList = .AllWords
        default:
            sourceList = nil
            break
        }
        
//        var l = )
        
//        println(addWordsFromList.description())
//                var n = NSNotification(name: addWordsFromListNotification, object: targetView)
    if let sourceList = sourceList {
        Globals.notificationAddWordsFromList.postNotification(sourceList)
    }
        
    table.deselectRowAtIndexPath(indexPath, animated: true)
        
//        NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationAddWordsFromList, object: Globals.addWordsFromList)
    }
}