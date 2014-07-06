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

class GameMode: UIViewController {
    
    @IBOutlet var outputText: UITextView
    
    var due: NSNumber[]
//    var lastDue: String = ""
    var isFront: Bool = true;
    
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    var dueCard: Card {
    get {
        return fetchCardByIndex(due[0], self.managedObjectContext)
    }
    }
    
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
//    var lastDueCard: Card {
//    get {
//        return fetchCardByKanji(lastDue, self.managedObjectContext)
//    }
//    }
    
    init(coder aDecoder: NSCoder!) {
        self.due = []
        super.init(coder: aDecoder)
        
        initCoreData()
        
        self.due = loadDatabase()
        
        if self.due.count == 0
        {
            createDatabase("AllCards copy")
            self.due = loadDatabase()
        }
        
        //println(self.due.count)
    }
    
    func initCoreData()
    {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        
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
                card.dueTime = 0
                
                //saveContext(self.managedObjectContext)
                
                value += card
            }
        }
        
        saveContext(self.managedObjectContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        
        //var card = fetchCardByKanji(due[0], self.managedObjectContext)
        
        if(isFront) {
            outputText.attributedText = dueCard.front
        }
        else {
            outputText.attributedText = dueCard.back
        }
        
        outputText.textAlignment = .Center
    }
  
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
    
    func loadDatabase () -> NSNumber[] {
        //println("-- Fetch action --")
        
        var values: NSNumber[] = []
        
        if let allCards = fetchCardsGeneral(CoreDataEntities.Card, CardProperties.kanji, self.managedObjectContext) {
            
            for item : AnyObject in allCards {
                var card = item as Card
                
                values += card.index
            }
        }
        
        return values
//        if let mySinglearray: AnyObject[] = myNameFetchRequest(CoreDataEntities.Card, CardProperties.kanji, "Bill", self.managedObjectContext) {
//            println("(--  --)")
//            printFetchedArrayList(mySinglearray)
//        }
        
    }
    
    func saveContext (context: NSManagedObjectContext) {
        var error: NSError? = nil
        context.save(&error)
    }
    
    func loadContext () {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    func myLoad () {
        loadContext ()
        println("Loaded Context")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLoad ()
        updateText()
        setupSwipeGestures()
    }
    
    func advanceCard()
    {
        if !isFront && due.count > 1 {
            
            due.removeAtIndex(0)
        }
        
        isFront = !isFront
        
        updateText()
    }
    
    func onInteract(interactType: InteractType, _ card: Card) {
        
        switch interactType {
            
        case .Tap:
            card.answerCard(.Normal)
            
        case .SwipeRight:
            println("Swiped right \(card.kanji)")
            card.answerCard(.Hard)
            due += due[0]
            
        case .SwipeLeft:
            println("Swiped Left \(card.kanji)")
            card.answerCard(.Forgot)
            due += due[0]
            
        case .SwipeUp:
            println("Swiped Up \(card.kanji)")
            card.answerCard(.Easy)
            
        case .SwipeDown:
            println("Swipe Down \(card.kanji)")
        }
        advanceCard()
        
        saveContext(self.managedObjectContext)
    }
    
    @IBAction func onTap () {
        
        if !isFront {
            
            onInteract(.Tap, dueCard)
        }
        else
        {
            advanceCard()
        }
        
//        if !isFront {
//            lastDue = due[0]
//        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if !isFront {
                
                switch swipeGesture.direction {
                    
                case UISwipeGestureRecognizerDirection.Right:
                    onInteract(.SwipeRight, dueCard)
                    
                case UISwipeGestureRecognizerDirection.Down:
                    onInteract(.SwipeDown, dueCard)
                    
                case UISwipeGestureRecognizerDirection.Up:
                    onInteract(.SwipeUp, dueCard)
                    
                case UISwipeGestureRecognizerDirection.Left:
                    onInteract(.SwipeLeft, dueCard)
                    
                default:
                    break
                }
            }
        }
    }
    
    func setupSwipeGestures(){
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
}