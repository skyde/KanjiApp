//
//  SidebarMenu.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-22.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

class SidebarMenu: UITableViewController {
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.back
        // 150 for text
        self.view.backgroundColor = UIColor(white: 0.19 + 1.0 / 255, alpha: 1)
    }
}