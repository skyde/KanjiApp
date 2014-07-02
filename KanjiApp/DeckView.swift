//
//  DeckView.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-02.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DeckView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView
    var items: String[] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        
        items = []
        
        if let allCards = fetchCardsGeneral(CoreDataEntities.Card, CardProperties.kanji, context) {
            printFetchedArrayList(allCards)
            
            for item : AnyObject in allCards {
                
                var card = item as Card
                items += card.kanji
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