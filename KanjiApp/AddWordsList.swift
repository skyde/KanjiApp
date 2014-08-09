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
        
        switch indexPath.row {
        case 0:
            Globals.addWordsFromList = .MyWords
        case 1:
            Globals.addWordsFromList = .Jlpt4
        case 2:
            Globals.addWordsFromList = .Jlpt3
        case 3:
            Globals.addWordsFromList = .Jlpt2
        case 4:
            Globals.addWordsFromList = .Jlpt1
        case 5:
            Globals.addWordsFromList = .AllWords
        default:
            break
        }
        
        var l = Container(Globals.addWordsFromList)
        
//        println(addWordsFromList.description())
//                var n = NSNotification(name: addWordsFromListNotification, object: targetView)
        NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationAddWordsFromList, object: l)
    }
}