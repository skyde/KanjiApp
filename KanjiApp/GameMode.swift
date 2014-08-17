import UIKit
import CoreData
import AVFoundation

class GameMode: CustomUIViewController, AVAudioPlayerDelegate {
    @IBOutlet var outputText: UITextView!
    
    var due: [NSNumber]
    var isFront: Bool = true
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var addRemoveSidebar: UIView!
    var edgeReveal: EdgeReveal! = nil
    
    var dueCard: Card? {
    get {
        if due.count > 0 {
            return managedObjectContext.fetchCardByIndex(due[0])
        }
        return nil
    }
    }
    
    var cardPropertiesSidebar: CardPropertiesSidebar {
        return self.childViewControllers[0] as CardPropertiesSidebar
    }

    @IBOutlet weak var kanjiView: UILabel!
    
    required init(coder aDecoder: NSCoder!) {
        self.due = []
        super.init(coder: aDecoder)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeGestures()
        setupEdgeReveal()
        
        Globals.notificationEditCardProperties.addObserver(self, selector: "onEditCard", object: nil)
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "onSidebarInteract", object: nil)
    }
    
    func onSidebarInteract() {
        edgeReveal.animateSidebar(false)
    }
    
    func onEditCard() {
        if !view.hidden {
            edgeReveal.editCardProperties(dueCard, value: Globals.notificationEditCardProperties.value)
            
            saveContext()
        }
    }
    
    private func setupEdgeReveal() {
        
        edgeReveal = EdgeReveal(
            parent: view,
            revealType: .Right,
            onUpdate: {(offset: CGFloat) -> () in
                self.outputText.frame.origin.x = -offset
                self.addRemoveSidebar.frame.origin.x = Globals.screenSize.width - offset
                self.kanjiView.frame.origin.x = -offset
                self.cardPropertiesSidebar.animate(offset)
            },
            setVisible: {(isVisible: Bool) -> () in
                if let card = self.dueCard {
                    self.cardPropertiesSidebar.updateContents(card)
                }
                self.addRemoveSidebar.hidden = !isVisible
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        due = managedObjectContext.fetchCardsActive().map { ($0 as Card).index }
        
        updateText()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if due.count == 0 {
            Globals.notificationTransitionToView.postNotification(.CardsFinished)
        }
    }
    
    func advanceCard() {
        if !isFront && due.count >= 1 {
            
            due.removeAtIndex(0)
        }
        
        if due.count == 0 {
            Globals.notificationTransitionToView.postNotification(.CardsFinished)
        } else {
            isFront = !isFront
            
            if !isFront
            {
                if var path = dueCard?.embeddedData.soundWord
                {
                    playSound(filterSoundPath(path))
                }
            }
            
            updateText()
        }
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
        
        if var path = dueCard?.embeddedData.soundDefinition
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
            due.append(due[0])
        case .SwipeLeft:
            println("Swiped Left \(card.kanji)")
            card.answerCard(.Forgot)
            due.append(due[0])
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
    }
}