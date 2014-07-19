import UIKit
import CoreData

class GameMode: CustomUIViewController {
    @IBOutlet var outputText: UITextView
    
    var due: [NSNumber]
    var isFront: Bool = true;
    
    var dueCard: Card? {
    get {
        if due.count > 0 {
            return managedObjectContext.fetchCardByIndex(due[0])
        }
        return nil
    }
    }
    
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    init(coder aDecoder: NSCoder!) {
        self.due = []
        super.init(coder: aDecoder)
        
        self.due = loadDatabase()
        
        if !settings.generatedCards.boolValue {
            settings.generatedCards = true
            createDatabase("AllCards copy")
        }
        
        self.due = loadDatabase()
    }
    
    func createDatabase(filename: String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        
        var values: [Card] = []
        
        if let content = possibleContent {
            var deck = content.componentsSeparatedByString("\n")
            for deckItem in deck {
                var items = deckItem.componentsSeparatedByString("\t")
                
                var index: Int = items[1].toInt()!
                var pitchAccent = 0
                if var p = items[12].toInt() {
                    pitchAccent = p
                }
                
                var usageAmount = 0
                if var u = items[9].toInt() {
                    usageAmount = u
                }
                
                var jlptLevel = 0
                if var j = items[10].toInt() {
                    jlptLevel = j
                }
                
                let kanji = items[0]
                
                var card = managedObjectContext.fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji, createIfNil: true)! as Card
                
                card.kanji = kanji
                
                card.index = index
                card.hiragana = items[2]
                card.definition = items[3]
                card.exampleEnglish = items[4]
                card.exampleJapanese = items[5]
                card.soundWord = items[6]
                card.soundDefinition = items[7]
                card.definitionOther = items[8]
                card.usageAmount = usageAmount
                card.jlptLevel = jlptLevel
                card.pitchAccentText = items[11]
                card.pitchAccent = pitchAccent
                card.otherExampleSentences = items[13]
                card.answersKnown = 0
                card.answersNormal = 0
                card.answersHard = 0
                card.answersForgot = 0
                card.interval = 0
                card.dueTime = 0
                
                values += card
            }
        }
        
        saveContext()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        if let card = dueCard {
            if isFront {
                outputText.attributedText = card.front
            }
            else {
                outputText.attributedText = card.back
            }
            outputText.textAlignment = .Center
        }
    }
    
    func loadDatabase () -> [NSNumber] {
        var values: [NSNumber] = []
        
        let allCards = managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, "true")], CardProperties.interval, sortAscending: true)
        
        for item in allCards {
            var card = item as Card
            values += card.index
        }
        
        return values
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupSwipeGestures()
        
        if due.count == 0 {
            self.navigationController.popToRootViewControllerAnimated(false)
            self.performSegueWithIdentifier("AddFromList", sender: self)
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if segue!.identifier == "AddFromListSegue" {
//            // pass data to next view
//        }
//    }
    
    func advanceCard() {
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
        saveContext()
    }
    
    @IBAction func onTap () {
        if let card = dueCard {
            if !isFront {
                onInteract(.Tap, card)
            }
            else {
                advanceCard()
            }
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if !isFront {
                if let card = dueCard {
                    switch swipeGesture.direction {
                        
                    case UISwipeGestureRecognizerDirection.Right:
                        onInteract(.SwipeRight, card)
                        
                    case UISwipeGestureRecognizerDirection.Down:
                        onInteract(.SwipeDown, card)
                        
                    case UISwipeGestureRecognizerDirection.Up:
                        onInteract(.SwipeUp, card)
                        
                    case UISwipeGestureRecognizerDirection.Left:
                        onInteract(.SwipeLeft, card)
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func setupSwipeGestures() {
//        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        self.view.addGestureRecognizer(swipeRight)
//        
//        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
//        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
//        self.view.addGestureRecognizer(swipeDown)
//        
//        var swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
//        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
//        self.view.addGestureRecognizer(swipeUp)
//        
//        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
//        self.view.addGestureRecognizer(swipeLeft)
//        
//        var swipeFromLeftEdge = UIScreenEdgePanGestureRecognizer(target: self, action: "respondToSwipeFromLeft:")
//        swipeFromLeftEdge.edges = UIRectEdge.Left
//        self.view.addGestureRecognizer(swipeFromLeftEdge)
        
//        swipeFromLeftEdge.addTarget(self, action: "respondToSwipeGesture:")
//        self.view.addGestureRecognizer(swipeFromLeftEdge)
    }
    
//    @IBOutlet var swipeFromLeftEdge : UIScreenEdgePanGestureRecognizer = nil
}