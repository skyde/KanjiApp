//
//  SidebarMenu.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-22.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

class SidebarMenu: UITableViewController, UITableViewDelegate {
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.back
        // 150 for text
        var bkColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
        self.view.backgroundColor = bkColor
    }

//    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        return 11;
//    }
    override func viewDidAppear(animated: Bool) {
        
//        var root = (self.parentViewController as RootContainer)
//        
        //        println(root.mainView.subviews[0] as UINavigationController)
//        var bkColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
//        table.headerViewForSection(0).textLabel.backgroundColor = bkColor
//        table.headerViewForSection(0).contentView.backgroundColor = bkColor
    }
    
//    override func onTransitionToView(notification: NSNotification) {
//        //        super.onTransitionToView(notification)
//        
//        animateSelf(false)
//    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        var targetView: View
        
        switch indexPath.section * 100 + indexPath.row {
        case 0:
            targetView = .Search
        case 1:
            targetView = .GameMode
        case 2:
            targetView = .Reader
        case 3:
            let myWords = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
            var exclude = [WordList.MyWords]
            
            if myWords.count > 0 {
                exclude = []
            }
            
            targetView = .AddWords(exclude: exclude)
        case 100:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, true), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "My Words", cards: cards)
        case 101:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "Will Study", cards: cards)
        case 200:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.jlptLevel, 4), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 4", cards: cards)
        case 201:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.jlptLevel, 3), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 3", cards: cards)
        case 202:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.jlptLevel, 2), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 2", cards: cards)
        case 203:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.jlptLevel, 1), (CardProperties.suspended, true)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "JLPT 1", cards: cards)
        case 204:
            var cards = RootContainer.instance.managedObjectContext.fetchEntities(.Card, [(CardProperties.suspended, true)], CardProperties.interval, sortAscending: true).map { ($0 as Card).index }
            
            targetView = .Lists(title: "All Words", cards: cards)
//            Globals.viewCards =
        case 300:
            targetView = .Settings
        default:
            targetView = .Search
            break
        }
        
        Globals.notificationTransitionToView.postNotification(targetView)
    }
}