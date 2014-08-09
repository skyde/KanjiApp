import Foundation
import UIKit
import CoreData

class Lists: CustomUIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var items: [NSNumber] = []
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        items = []
    }
    
    @IBAction func onButtonDown(sender: AnyObject) {
        println("on down")
        Globals.notificationTransitionToView.postNotification(.GameMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
//        var cards = Globals.viewCards//managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, true), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
        items = Globals.viewCards
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