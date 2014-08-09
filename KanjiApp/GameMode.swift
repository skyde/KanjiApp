import UIKit
import CoreData
import AVFoundation

class GameMode: CustomUIViewController, AVAudioPlayerDelegate {
    @IBOutlet var outputText: UITextView!
    
    var due: [NSNumber]
    var isFront: Bool = true
    var audioPlayer = AVAudioPlayer()
    
    var dueCard: Card? {
    get {
        if due.count > 0 {
            return managedObjectContext.fetchCardByIndex(due[0])
        }
        return nil
    }
    }
    
    @IBOutlet weak var kanjiView: UILabel!
    
//    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    init(coder aDecoder: NSCoder!) {
        self.due = []
        super.init(coder: aDecoder)
        
        self.due = loadDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateText() {
        
        if let card = dueCard {
            if isFront {
                card.setFrontText(kanjiView)
                outputText.text = ""
            }
            else {
                kanjiView.text = ""
                outputText.attributedText = card.back
            }
            outputText.textAlignment = .Center
            outputText.textContainerInset.top = 40
            outputText.scrollRangeToVisible(NSRange(location: 0, length: 1))
            outputText.scrollEnabled = !isFront
            
            kanjiView.enabled = isFront
            outputText.alpha = isFront ? 0 : 1
        }
    }
    
    func loadDatabase () -> [NSNumber] {
        var values: [NSNumber] = []
        
        let cards = managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, true), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
        
//        println((cards[0] as Card).enabled)
        
        return cards.map { ($0 as Card).index }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupSwipeGestures()
        
        if due.count == 0 {
            
            let myWords = managedObjectContext.fetchEntities(.Card, [(CardProperties.enabled, false), (CardProperties.suspended, false)], CardProperties.interval, sortAscending: true)
            
            if myWords.count > 0 {
                Globals.addWordsFromList = .MyWords
                Globals.autoAddWordsFromList = true
            }
            
//            transitionToView()
            Globals.notificationTransitionToView.postNotification(View.AddWords)
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
        
        if !isFront
        {
            if var path = dueCard?.soundWord
            {
                playSound(filterSoundPath(path))
            }
        }
        
        updateText()
    }
    
    func filterSoundPath(path: String) -> String
    {
        var range: NSRange = NSRange(location: 7, length: countElements(path) - 12)
        return (path as NSString).substringWithRange(range)
    }
    
    func playSound(name: String, fileType: String = "mp3", var sendEvents: Bool = true) {
        var resourcePath = NSBundle.mainBundle().pathForResource(name, ofType: fileType)
        
        if let resourcePath = resourcePath {
            var sound = NSURL(fileURLWithPath: resourcePath)
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: &error)
            if sendEvents {
                audioPlayer.delegate = self
            }
            audioPlayer.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        
        if var path = dueCard?.soundDefinition
        {
            if !isFront
            {
                playSound(filterSoundPath(path), sendEvents: false)
            }
        }
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
            break
//            println("Swiped Up \(card.kanji)")
//            card.answerCard(.Easy)
        case .SwipeDown:
            break
//            println("Swipe Down \(card.kanji)")
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
        
        var swipeFromLeftEdge = UIScreenEdgePanGestureRecognizer(target: self, action: "respondToSwipeFromLeft:")
        swipeFromLeftEdge.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(swipeFromLeftEdge)
        
        swipeFromLeftEdge.addTarget(self, action: "respondToSwipeGesture:")
        self.view.addGestureRecognizer(swipeFromLeftEdge)
    }
    
//    @IBOutlet var swipeFromLeftEdge : UIScreenEdgePanGestureRecognizer = nil
}