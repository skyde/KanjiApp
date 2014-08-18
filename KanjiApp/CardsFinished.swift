//
//  CardsFinished.swift
//  KanjiApp
//
//  Created by Sky on 2014-08-14.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

class CardsFinished : CustomUIViewController {
    
    @IBOutlet weak var continueStudying: UIButton!
    
    @IBAction func continueStudyingPressed(sender: AnyObject) {
//        println("continueStudyingPressed")
        var studyAheadAmount: Double = 60 * 60 * 24 * 5
        Globals.notificationTransitionToView.postNotification(.GameMode(studyAheadAmount: studyAheadAmount))
    }
    
    @IBAction func addNewCardsPressed(sender: AnyObject) {
//        println("addNewCardsPressed")
        
        let myWords = managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
        
        if myWords.count > 0 {
            Globals.notificationAddWordsFromList.postNotification(.MyWords)
        }
        else {
            Globals.notificationTransitionToView.postNotification(.AddWords(enableOnAdd: true))
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let active = managedObjectContext.fetchCardsActive()
        
        continueStudying.enabled = active.count != 0
    }
}