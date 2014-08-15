import Foundation
import UIKit
import CoreData

class Lists: CustomUIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var items: [NSNumber] = []
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        items = []
    }
    
    @IBAction func onButtonDown(sender: AnyObject) {
        for index in items {
            if let card = managedObjectContext.fetchCardByIndex(index) {
                card.enabled = true
                card.suspended = false
            }
        }
        
        saveContext()
        
        Globals.notificationTransitionToView.postNotification(.GameMode)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Globals.notificationTransitionToView.value {
        case .Lists(let title, let cards, let displayAddButton):
            items = cards
            header.text = title
            confirmButton.hidden = !displayAddButton
        default:
            break
        }
        

    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row]) {
            cell.textLabel.attributedText = card.cellText
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