import Foundation
import UIKit

class SidebarMenu: UITableViewController, UITableViewDelegate {
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var bkColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
//        self.view.backgroundColor = bkColor
//        table.headerViewForSection(1).textLabel.font = UIFont(name: Globals.JapaneseFont, size: 16)
//        println(table.®)
    }

//    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
//        
//        var label  = UILabel(frame: CGRectMake(0, 0, view.frame.width, 20))
//        label.font = UIFont(name: Globals.JapaneseFont, size: 16)
//        label.text = tableView.headerViewForSection(section).description
//        
//        var add = UIView()
//        add.addSubview(label)
//        
//        return add
//    }
//    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        return 11;
//    }
    
//    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
//        
//        if section == 1 || section == 2 || section == 3 {
//            return 30
//        }
//        
//        return 0
//    }
    
    override func viewDidAppear(animated: Bool) {
        
//        var root = (self.parentViewController as RootContainer)
//        
        //        println(root.mainView.subviews[0] as UINavigationController)
        var bkColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
        //        table.headerViewForSection(0).textLabel.backgroundColor = bkColor
        //        table.headerViewForSection(0).contentView.backgroundColor = bkColor
//        println("did appear")
        for i in 0 ..< table.numberOfSections() {
            if let header = table.headerViewForSection(i) {
                header.textLabel.font = UIFont(name: Globals.JapaneseFont, size: 16)
                header.textLabel.textColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
//                header.textLabel.textAlignment = NSTextAlignment.Left
                header.backgroundView.backgroundColor = bkColor
                
//                header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.width, 10)
            }
        }
        
//        println(table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).textLabel.textColor)
        
        Globals.colorFunctions = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).textLabel.textColor
        Globals.colorMyWords = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)).textLabel.textColor
        Globals.colorKnown = table.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)).textLabel.textColor
        Globals.colorLists = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)).textLabel.textColor
        Globals.colorOther = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)).textLabel.textColor
    }
    
//    override func onTransitionToView(notification: NSNotification) {
//        //        super.onTransitionToView(notification)
//        
//        animateSelf(false)
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//            }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        var targetView: View
        
        switch indexPath.section * 100 + indexPath.row {
        case 0:
            targetView = .Search
        case 1:
            targetView = .GameMode(studyAheadAmount: 0)
        case 2:
            targetView = .Reader
        case 3:
//            let myWords = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
//            var exclude = [WordList.MyWords]
//            
//            if myWords.count > 0 {
//                exclude = []
//            }
            
            targetView = .AddWords(enableOnAdd: false)
        case 100:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsActive().map { ($0 as Card).index }
            
            targetView = .Lists(title: "Studying", color: Globals.colorMyWords, cards: cards, displayAddButton: false, enableOnAdd: false)
        case 101:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsWillStudy().map { ($0 as Card).index }
            
            targetView = .Lists(title: "Will Study", color: Globals.colorMyWords, cards: cards, displayAddButton: false, enableOnAdd: false)
        case 102:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsKnown().map { ($0 as Card).index }
            
            targetView = .Lists(title: "Known", color: Globals.colorKnown, cards: cards, displayAddButton: false, enableOnAdd: false)
        case 200:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT4Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 4", color: Globals.colorLists, cards: cards, displayAddButton: false, enableOnAdd: false)
        case 201:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT3Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 3", color: Globals.colorLists, cards: cards, displayAddButton: false, enableOnAdd: false)
        case 202:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT2Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 2", color: Globals.colorLists, cards: cards, displayAddButton: false, enableOnAdd: false)
        case 203:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT1Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 1", color: Globals.colorLists, cards: cards, displayAddButton: false, enableOnAdd: false)
//        case 204:
//            var cards = RootContainer.instance.managedObjectContext.fetchCardsAllWordsSuspended().map { ($0 as Card).index }
//            targetView = .Lists(title: "All Words", cards: cards, displayAddButton: false)
////            Globals.viewCards =
        case 300:
            targetView = .Settings
        default:
            targetView = .Search
            break
        }
        
        table.deselectRowAtIndexPath(indexPath, animated: true)
        
        Globals.notificationTransitionToView.postNotification(targetView)
    }
}