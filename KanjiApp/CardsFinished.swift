//
//  CardsFinished.swift
//  KanjiApp
//
//  Created by Sky on 2014-08-14.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation

class CardsFinished : CustomUIViewController {
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let myWords = managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
        
        if myWords.count > 0 {
        Globals.notificationAddWordsFromList.value = .MyWords
        Globals.autoAddWordsFromList = true
        }
    }
}