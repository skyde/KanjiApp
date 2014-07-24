//
//  MainMenu.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-23.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation

class RootMenu: CustomUIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        performSegueWithIdentifier(targetView.description(), sender: self)
    }
    
    override func isGameView() -> Bool {
        return false
    }
}