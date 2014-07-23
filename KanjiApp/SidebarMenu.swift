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
        self.view.backgroundColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
        
    }

//    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        return 11;
//    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        println("You selected cell #\(indexPath.row)!")
    }
}