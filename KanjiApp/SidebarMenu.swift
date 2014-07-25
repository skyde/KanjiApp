//
//  SidebarMenu.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-22.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

let TransitionToViewNotification = "TransitionToViewNotification"

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
        var bkColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
        table.headerViewForSection(0).textLabel.backgroundColor = bkColor
        table.headerViewForSection(0).contentView.backgroundColor = bkColor
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        //println("You selected cell #\(indexPath.row)!")
        
        //Search
        //Lists
        //Settings
        
        switch indexPath.section * 100 + indexPath.row {
        case 0:
            targetView = .Search
        case 1:
            targetView = .GameMode
        case 2:
            targetView = .Reader
        case 3:
            targetView = .AddWords
        case 100:
            targetView = .Lists
        default:
            break
        }
        
//        var n = NSNotification(name: TransitionToView, object: targetView)
        NSNotificationCenter.defaultCenter().postNotificationName(TransitionToViewNotification, object: nil)
    }
}