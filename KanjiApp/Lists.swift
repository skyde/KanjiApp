import Foundation
import UIKit
import CoreData

class Lists: CustomUIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var items: [NSNumber] = []
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var addWordsButton: UIButton!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        items = []
    }
    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        return tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
//    }
    
    @IBAction func onConfirmButtonDown(sender: AnyObject) {
        for index in items {
            if let card = managedObjectContext.fetchCardByIndex(index) {
                if !card.known.boolValue {
                    card.suspended = false
                }
                
                if enableOnAdd {
                    card.enabled = true
                }
//                card.known = false
            }
        }
        
        saveContext()
        
        Globals.notificationTransitionToView.postNotification(.GameMode(studyAheadAmount: 0, runTutorial: false))
    }
    
    @IBAction func onAddWordsButtonDown(sender: AnyObject) {
        
        if let sourceList = sourceList {
            Globals.notificationAddWordsFromList.postNotification(sourceList)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    var enableOnAdd: Bool = false
    var sourceList: WordList? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Globals.notificationTransitionToView.value {
        case .Lists(let title, let color, let cards, let displayConfirmButton, var displayAddButton, let sourceList, let enableOnAdd):
            
            if cards.count == 0 {
                displayAddButton = false
            }
            
            items = cards
            if  sourceList == WordList.Jlpt1 ||
                sourceList == WordList.Jlpt2 ||
                sourceList == WordList.Jlpt3 ||
                sourceList == WordList.Jlpt4 ||
                sourceList == WordList.AllWords ||
                cards.count == 0 {
                    header.text = "\(title)"
            } else {
                header.text = "\(title) (\(cards.count))"
            }
            header.textColor = color
            confirmButton.visible = displayConfirmButton
            addWordsButton.visible = displayAddButton
            self.enableOnAdd = enableOnAdd
            self.sourceList = sourceList
        default:
            break
        }
        

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row]) {
            cell.textLabel?.attributedText = card.cellText
        }
//        cell.detailTextLabel.text = card.definition
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        if var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row]) {
            
            Globals.notificationShowDefinition.postNotification(card.kanji)
            
//            Globals.currentDefinition = card.kanji
//            NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationShowDefinition, object: nil)
        }
    }
}