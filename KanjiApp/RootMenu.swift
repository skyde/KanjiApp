//
//  MainMenu.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-23.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation

class RootMenu: CustomUIViewController {
    
    override func isGameView() -> Bool {
        return false
    }
    
    override func receiveTransitionToViewNotifications() -> Bool {
        return false
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        performSegueWithIdentifier(Globals.targetView.description(), sender: self)
    }
}