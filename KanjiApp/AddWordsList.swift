import Foundation
import UIKit

class AddWordsList: UITableViewController, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        var bkColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
////        self.view.backgroundColor = bkColor
//    }
    
    override func viewDidAppear(animated: Bool) {
        
        table.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0
            ), animated: false, scrollPosition: .Top)    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        var sourceList: WordList
        
        switch indexPath.row {
        case 0:
            sourceList = .MyWords
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
            sourceList = .MyWords
            break
        }
        
//        var l = )
        
//        println(addWordsFromList.description())
//                var n = NSNotification(name: addWordsFromListNotification, object: targetView)
        
    Globals.notificationAddWordsFromList.postNotification(sourceList)
        
//        NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationAddWordsFromList, object: Globals.addWordsFromList)
    }
}