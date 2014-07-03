import Foundation
import UIKit
import CoreData

class DeckView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView
    var items: String[] = []
    
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    func loadContext () {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        items = []
        
        loadContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let allCards = fetchCardsGeneral(CoreDataEntities.Card, CardProperties.kanji, self.managedObjectContext) {
            //printFetchedArrayList(allCards)
            
            for item : AnyObject in allCards {
                
                var card = item as Card
                items += "\(card.kanji) \(card.interval)"
            }
        }

    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        cell.textLabel.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
}