//
//  ViewController.swift
//  KanjiApp
//
//  Created by Sky on 2014-06-10.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataEntities {
    case Card
    func description() -> String {
        switch self {
        case .Card:
            return "Card"
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet var outputText: UILabel
    
//    let deck: Card[]
//    var due: Card[]
    var due: String[]
    
    var isFront: Bool = true;
    
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    init(coder aDecoder: NSCoder!) {
//        self.deck = []
        
        //        self.due = [Card("挨拶", "あいさつ", "a greeting", "She greeted him with a smile.", "彼女は笑顔で挨拶した。", 1),
        //            Card("報告", "ほうこく", "report", "There's a report about yesterday's meeting.", "昨日の会議について報告があります。", 0),
        //            Card("繊細", "せんさい", "delicate; fine", "She is a very delicate person.", "彼女はとても繊細な人です", 0)]
        
        self.due = []
//        self.dueIDs = []
        
        super.init(coder: aDecoder)
        
        initCoreData()
        println("run init")
        
        createDatabase("AllCards")
        
        //makeEntityAction()
        
        self.due = loadDatabase()
        println(self.due.count)
        
//        for card in self.due {
//            var loaded : AnyObject? = fetchCard(CardProperties.kanji, card, self.managedObjectContext)
//            
//            println("created kanji \(loaded)")
//        }
        
        //self.due = LoadAllCards("AllCards");
    }
    
    func initCoreData()
    {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        let entityName: String = "Card"
        let myEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        var card = Card(entity: myEntityDescription, insertIntoManagedObjectContext: context)
        
        self.managedObjectContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
    }
    
    func createDatabase(filename: String)
    {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        
        var value: Card[] = []
        
        if let content = possibleContent {
            var deck = content.componentsSeparatedByString("\n")
            
            for deckItem in deck
            {
                var items = deckItem.componentsSeparatedByString("\t")
                
                var index: Int = items[1].toInt()!
                var pitchAccent = 0
                if var p = items[12].toInt()
                {
                    pitchAccent = p
                }
                
                var usageAmount = 0
                if var u = items[9].toInt()
                {
                    usageAmount = u
                }
                
                let kanji = items[0]
                
                var card = Card.createCard(CardProperties.kanji, value : kanji, context: self.managedObjectContext)!
                
                card.index = index
                card.hiragana = items[2]
                card.definition = items[3]
                card.exampleEnglish = items[4]
                card.exampleJapanese = items[5]
                card.soundWord = items[6]
                card.soundDefinition = items[7]
                card.definitionOther = items[8]
                card.usageAmount = usageAmount
                card.usageAmountOther = 0
                card.pitchAccentText = items[11]
                card.pitchAccent = pitchAccent
                card.otherExampleSentences = items[13]
                
                card.answersKnown = 0
                card.answersNormal = 0
                card.answersHard = 0
                card.answersForgot = 0
                card.interval = 0
                
                saveContext(self.managedObjectContext)
                
                value += card
                //                let kanji = ""
                //                let index = 0
                //                let hiragana = ""
                //                let definition = ""
                //                let exampleEnglish = ""
                //                let exampleJapanese = ""
                //                let soundWord = ""
                //                let soundDefinition = ""
                //                let definitionOther = ""
                //                let usageAmount = 0
                //                let usageAmountOther = 0
                //                let pitchAccentText = 0
                //                let pitchAccent = 0
                //                let otherExampleSentences = 0
                
                //                var i: Int = 0
                //                for item in )
                //                {
                //                    println(item)
                //                    println("\n")
                //
                //                    switch i
                //                    {
                //                        case 0:
                //
                //
                //                    }
                //
                //                    i++
                //                }
            }
        }
        
        //print(value.count(<#r: Range<I>#>))
        
        saveContext(self.managedObjectContext)
        
        //return value
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap () {
        if(!isFront && due.count > 1) {
            due.removeAtIndex(0)
        }
        
        isFront = !isFront
        
        updateText()
    }
    
    func updateText() {
        
        var card = fetchCardByKanji(due[0], self.managedObjectContext)
        
        if(isFront) {
            outputText.attributedText = card.front
        }
        else {
            outputText.attributedText = card.back
        }
    }
//    
//    func makeEntityAction () {
//        println("-- Make action --")
//        
//        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        let value = "例　ExKanji with interval of 22"
//        
//        var card = Card.createCard(CardProperties.kanji, value : value, context: self.managedObjectContext)!
//        
//        card.interval = 22
//        card.definition = "Test Definition"
//        
//        saveContext(self.managedObjectContext)
//        //saveContext(appDelegate.managedObjectContext)
//    }
    
    func loadDatabase () -> String[] {
        println("-- Fetch action --")
        
        var values: String[] = []
        
        if let allCards = fetchCardsGeneral(CoreDataEntities.Card, CardProperties.kanji, self.managedObjectContext) {
            printFetchedArrayList(allCards)
            
            for item : AnyObject in allCards {
                var card = item as Card
                
//                if card.definition != nil {
//                    println("definition = \(card.definition)")
//                }
//                //                }
//                println("kanji = \(card.kanji)")
//                println("interval = \(card.interval)")
                
                values += card.kanji
            }
        }
        
        return values
//        if let mySinglearray: AnyObject[] = myNameFetchRequest(CoreDataEntities.Card, CardProperties.kanji, "Bill", self.managedObjectContext) {
//            println("(--  --)")
//            printFetchedArrayList(mySinglearray)
//        }
        
    }
    
    //
    //// LOAD & SAVE
    //
    
    func loadContext () {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    func saveContext (context: NSManagedObjectContext) {
        var error: NSError? = nil
        context.save(&error)
    }
    
    //
    //// LOAD
    //
    
    func myLoad () {
        loadContext ()
        println("Loaded Context")
    }
    
    //
    //// Life Cycle
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLoad ()
        //updateText()
    }
}