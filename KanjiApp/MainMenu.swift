//
//  MainMenu.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-23.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation

class MainMenu: CustomUIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Now In Menu " + targetView)
        performSegueWithIdentifier(targetView, sender: self)
    }
    
    override func isGameView() -> Bool {
        return false
    }
}