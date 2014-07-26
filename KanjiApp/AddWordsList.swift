import Foundation
import UIKit

let addWordsFromListNotification = "addWordsFromListNotification"
var addWordsFromList: WordList = WordList.AllWords

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
            addWordsFromList = .MyWords
        case 1:
            addWordsFromList = .Jlpt4
        case 2:
            addWordsFromList = .Jlpt3
        case 3:
            addWordsFromList = .Jlpt2
        case 4:
            addWordsFromList = .Jlpt1
        case 5:
            addWordsFromList = .AllWords
        default:
            break
        }
        
        println(addWordsFromList.description())
//                var n = NSNotification(name: addWordsFromListNotification, object: targetView)
        NSNotificationCenter.defaultCenter().postNotificationName(addWordsFromListNotification, object: nil)
    }
}