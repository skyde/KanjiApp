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
        Globals.notificationSidebarInteract.addObserver(self, selector: "refreshDisplay")
    }
    @IBOutlet weak var studyLabel: UILabel!

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
    
//    var didAppear = false
    func refreshDisplay() {
        var due = RootContainer.instance.managedObjectContext.fetchCardsDue(fetchAheadAmount: 0)
        studyLabel.text = due.count == 0 ? "Study" : "Study (\(due.count))"
    }
    
    override func viewDidAppear(animated: Bool) {
//        println("viewdidappear")
        refreshDisplay()

//        didAppear = true
//        var root = (self.parentViewController as RootContainer)
//        
        //        println(root.mainView.subviews[0] as UINavigationController)
        var bkColor = UIColor(red: 55, green: 53, blue: 58, alpha: 1)
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
        reorderItems()
        
//        println(table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).textLabel.textColor)
        
//        Globals.colorFunctions = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)).textLabel.textColor
//        Globals.colorMyWords = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)).textLabel.textColor
//        Globals.colorKnown = table.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)).textLabel.textColor
//        Globals.colorLists = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)).textLabel.textColor
//        Globals.colorOther = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)).textLabel.textColor
    }
    
//    override func onTransitionToView(notification: NSNotification) {
//        //        super.onTransitionToView(notification)
//        
//        animateSelf(false)
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//            }
    
    var listsOpen = false
    var referencesOpen = false
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let baseHeight: CGFloat = 44
        var listsHeight: CGFloat = baseHeight
        var referencesHeight: CGFloat = baseHeight
        
        if !listsOpen {
            listsHeight = 0
        }
        
        if !referencesOpen {
            referencesHeight = 0
        }
        
        if indexPath == NSIndexPath(forRow: 1, inSection: 1) ||
            indexPath == NSIndexPath(forRow: 2, inSection: 1) ||
            indexPath == NSIndexPath(forRow: 3, inSection: 1) ||
            indexPath == NSIndexPath(forRow: 4, inSection: 1) {
                return listsHeight
        }
        
        if indexPath == NSIndexPath(forRow: 1, inSection: 2) ||
            indexPath == NSIndexPath(forRow: 2, inSection: 2) ||
            indexPath == NSIndexPath(forRow: 3, inSection: 2) ||
            indexPath == NSIndexPath(forRow: 4, inSection: 2) {
                return referencesHeight
        }
        
        return baseHeight
    }
    
    private func refreshHeights() {
        table.beginUpdates()
        table.endUpdates()
        
        reorderItems()
    }
    
    private func reorderItems() {
        var cell1 = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))
        cell1?.superview?.bringSubviewToFront(cell1)
        var cell2 = table.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3))
        cell2?.superview?.bringSubviewToFront(cell2)
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        var targetView: View?
        
        switch indexPath.section * 100 + indexPath.row {
        case 1:
            targetView = .GameMode(studyAheadAmount: 0)
        case 2:
            targetView = .Search
        case 3:
            targetView = .Reader
        case 4:
//            let myWords = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
//            var exclude = [WordList.MyWords]
//            
//            if myWords.count > 0 {
//                exclude = []
//            }
            
            targetView = .AddWords(enableOnAdd: false)
        case 100:
            listsOpen = !listsOpen
            
            table.cellForRowAtIndexPath(indexPath).accessoryType = listsOpen ? .None : .DisclosureIndicator
            refreshHeights()
        case 101:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsActive().map { ($0 as Card).index }
            
            targetView = .Lists(
                title: Globals.textStudying,
                color: Globals.colorMyWords,
                cards: cards,
                displayConfirmButton: false,
                displayAddButton: false,
                sourceList: nil,
                enableOnAdd: false)
        case 102:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsWillStudy().map { ($0 as Card).index }
            
            targetView = .Lists(
                title: Globals.textPending,
                color: Globals.colorKnown,
                cards: cards,
                displayConfirmButton: false,
                displayAddButton: true,
                sourceList: .MyWords,
                enableOnAdd: false)
//        case 103:
//            var cards = RootContainer.instance.managedObjectContext.fetchCardsKnown().map { ($0 as Card).index }
//            
//            targetView = .Lists(
//                title: "Known",
//                color: Globals.colorKnown,
//                cards: cards,
//                displayConfirmButton: false,
//                displayAddButton: false,
//                sourceList: nil,
//                enableOnAdd: false)
        case 200:
            referencesOpen = !referencesOpen
            
            table.cellForRowAtIndexPath(indexPath).accessoryType = referencesOpen ? .None : .DisclosureIndicator
            
            refreshHeights()
        case 201:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT4Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(
                title: "JLPT 4",
                color: Globals.colorLists,
                cards: cards,
                displayConfirmButton: false,
                displayAddButton: true,
                sourceList: .Jlpt4,
                enableOnAdd: false)
        case 202:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT3Suspended().map { ($0 as Card).index }
             
            targetView = .Lists(
                title: "JLPT 3",
                color: Globals.colorLists,
                cards: cards,
                displayConfirmButton: false,
                displayAddButton: true,
                sourceList: .Jlpt3,
                enableOnAdd: false)
        case 203:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT2Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(
                title: "JLPT 2",
                color: Globals.colorLists,
                cards: cards,
                displayConfirmButton: false,
                displayAddButton: true,
                sourceList: .Jlpt2,
                enableOnAdd: false)
        case 204:
            var cards = RootContainer.instance.managedObjectContext.fetchCardsJLPT1Suspended().map { ($0 as Card).index }
            
            targetView = .Lists(
                title: "JLPT 1",
                color: Globals.colorLists,
                cards: cards,
                displayConfirmButton: false,
                displayAddButton: true,
                sourceList: .Jlpt1,
                enableOnAdd: false)
//        case 204:
//            var cards = RootContainer.instance.managedObjectContext.fetchCardsAllWordsSuspended().map { ($0 as Card).index }
//            targetView = .Lists(title: "All Words", cards: cards, displayAddButton: false)
////            Globals.viewCards =
        case 300:
            targetView = .Settings
        default:
            //targetView = .Search
            break
        }
        
        table.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let targetView = targetView {
            Globals.notificationTransitionToView.postNotification(targetView)
        }
    }
}