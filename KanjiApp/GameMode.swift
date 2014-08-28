import UIKit
import CoreData
import AVFoundation

//class CardStateEntry {
//    var index: NSNumber
//    var answersKnown: NSNumber
//    var answersNormal: NSNumber
//    var answersHard: NSNumber
//    var answersForgot: NSNumber
//    var interval: NSNumber
//    var dueTime: NSNumber
//    var enabled: NSNumber
//    var suspended: NSNumber
//    var known: NSNumber
//}

class GameMode: CustomUIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var outputText: UITextView!
    
    var due: [NSNumber] = []
    var undoStack: [NSNumber] = []
    var isFront: Bool = true
    var isBack: Bool {
    get {
        return !isFront
    }
    }
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var leftIndicator: UILabel!
    @IBOutlet weak var middleIndicator: UILabel!
    @IBOutlet weak var rightIndicator: UILabel!
    
    @IBOutlet weak var addRemoveSidebar: UIView!
    @IBOutlet weak var kanjiView: UILabel!
        @IBOutlet weak var undoSidebar: UIButton!
    @IBOutlet weak var redoSidebar: UIButton!
    
    var edgeReveal: EdgeReveal! = nil

    var dueCard: Card? {
    get {
        if due.count > 0 {
            return managedObjectContext.fetchCardByIndex(due[0])
        }
        return nil
    }
    }
    
    required init(coder aDecoder: NSCoder!) {
//        self.due = []
        super.init(coder: aDecoder)
    }
    
    var cardPropertiesSidebar: CardPropertiesSidebar {
        return self.childViewControllers[0] as CardPropertiesSidebar
    }
    
    var backTextCache: NSAttributedString! = nil

    func updateText() {
        if let card = dueCard {
            if isFront {
                card.setFrontText(kanjiView)
                outputText.text = ""
                backTextCache = card.back
            }
            else {
                if backTextCache == nil {
                    backTextCache = card.back
                }

                kanjiView.text = ""
                outputText.attributedText = backTextCache
                backTextCache = nil
            }
            kanjiView.hidden = !isFront
            outputText.textAlignment = .Center
            outputText.textContainerInset.top = 40
            outputText.scrollRangeToVisible(NSRange(location: 0, length: 1))
            
            kanjiView.enabled = isFront
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEdgeReveal()
        
        leftIndicator.hidden = true
        middleIndicator.hidden = true
        rightIndicator.hidden = true
        undoSidebar.hidden = true
        redoSidebar.hidden = true
        
        
        
//        var onSwipeToRight = UISwipeGestureRecognizer(target: self, action: "onSwipeToRight:")
//        onSwipeToRight.delegate = self
//        onSwipeToRight.direction = .Right
//        outputText.addGestureRecognizer(onSwipeToRight)
        
//        outputText.panGestureRecognizer.delegate = self
        
        var panGesture = UIPanGestureRecognizer(target: self, action: "onPan:")
        panGesture.delegate = self
        self.outputText.addGestureRecognizer(panGesture)
        
        var downGesture = UILongPressGestureRecognizer(target: self, action: "onDown:")
        downGesture.delegate = self
        downGesture.minimumPressDuration = 0
        downGesture.requireGestureRecognizerToFail(panGesture)
        self.outputText.addGestureRecognizer(downGesture)
        
//        var onTouchGesture = UITapGestureRecognizer(target: self, action: "onTouch:")
//        onTouchGesture.delegate = self
//        downGesture.requireGestureRecognizerToFail(onSwipeToRight)
//        outputText.addGestureRecognizer(onTouchGesture)
        
    }
    
    
    func onTouch(sender: UITapGestureRecognizer) {

        if edgeReveal.animationState != AnimationState.Closed {
            return
        }

//        if isFront {
//            advanceCard()
//        } else {
//            caculateAnswer(sender)
//        }
        //        println(sender.state)
        //        println(sender.locationOfTouch(0, inView: self.view))
        //
        //        return
        
    }
//    func onSwipeToRight(sender: UIGestureRecognizer) {
//        println("onSwipeToRight")
//        
//        onUndo()
//    }
    
    //    var wasFront = false
    private var downPosition: CGPoint! = nil
    private var lastPosition: CGPoint! = nil
    private var travelledDistance: CGFloat = 0
    func onDown(sender: UIPanGestureRecognizer) {
        
        let tapRadius: CGFloat = 3
        let maxTravelled: CGFloat = 6
        
        switch sender.state {
        case .Began:
            downPosition = sender.locationInView(view)
            lastPosition = downPosition
            travelledDistance = 0
            
        case .Changed:
            var pos = sender.locationInView(view)
//            println(pos)
//            println(lastPosition)
//            
//            println(distanceAmount(pos, lastPosition))
            travelledDistance += distanceAmount(pos, lastPosition)
            
            lastPosition = pos
        case .Ended:
            
            if edgeReveal.animationState == AnimationState.Closed {
                if travelledDistance < maxTravelled {
                    if isFront {
                        advanceCard()
                    } else {
                        caculateAnswer(sender)
                    }
                }
            }
        
        default:
            break
        }
    }
    
    func onPan(sender: UIPanGestureRecognizer) {
        if edgeReveal.animationState != AnimationState.Closed {
            return
        }
        
        let transitionThreshold: CGFloat = 30
        var x = sender.translationInView(view).x
        
        x = max(0, abs(x) - 15) * sign(x)
        
        contentsUpdate(x)
        sidebarUpdate(x)
        
        switch sender.state {
        case .Began:
            sidebarSetVisiblity(true)
        case .Ended:
            var contentsTargetX: CGFloat = 0
            var active = false
            var isRedo = false
            
            if x > transitionThreshold {
                contentsTargetX = Globals.screenSize.width
                active = true
            } else if x < -transitionThreshold {
                contentsTargetX = -Globals.screenSize.width
                active = true
                isRedo = true
            }
            
//            println(active)
            
            UIView.animateWithDuration(0.16,
                delay: 0,
                options: .CurveEaseOut,
                {
                    self.sidebarUpdate(0)
                    if active {
                        self.contentsUpdate(contentsTargetX)
                    } else {
                        self.contentsUpdate(0)
                    }
                },
                completion: { (_) -> () in
                    
                    self.sidebarSetVisiblity(false)
                    
                    if active {
                        if isRedo {
                            self.onRedo()
                        } else {
                            self.onUndo()
                        }
                        
                        self.contentsUpdate(-contentsTargetX)
                        UIView.animateWithDuration(0.16,
                            delay: 0,
                            options: .CurveEaseOut,
                            {
                                self.contentsUpdate(0)
    //                            self.contentsAlpha(1)
                            },
                            completion: nil
                        )
                    }

//                self.contentsUpdate(0)
            })

        default:
            break
        }
    }
    
//    private func contentsSetVisiblity(visible: Bool) {
//        
//    }
    //
    private func contentsAlpha(value: CGFloat) {
        outputText.alpha = value
        kanjiView.alpha = value
    }
    
    private func contentsUpdate(x: CGFloat) {
        outputText.frame.origin.x = x
        kanjiView.frame.origin.x = x
        
        var alpha: CGFloat = 1 - abs(x / Globals.screenSize.width)//1 - max(0, abs(x) - undoSidebar.frame.width) / (Globals.screenSize.width - undoSidebar.frame.width)
        alpha = alpha * alpha
        
        contentsAlpha(alpha)
    }
    
    private func sidebarSetVisiblity(visible: Bool) {
        undoSidebar.visible = visible
        redoSidebar.visible = visible
    }
    
    private func sidebarUpdate(var x: CGFloat) {
        
        if x != 0 {
            x = min(undoSidebar.frame.width, abs(x)) * sign(x)
        }
        
//        println(x)
        
        undoSidebar.frame.origin.x = x - undoSidebar.frame.width
        redoSidebar.frame.origin.x = x + Globals.screenSize.width
    }
    
    private func caculateAnswer(sender: UIGestureRecognizer) {
        var x = sender.locationInView(self.view).x / Globals.screenSize.width
        x *= 3
        
        if x >= 0 && x < 1 {
            answerCard(.Forgot)
        } else if x >= 1 && x <= 2 {
            answerCard(.Normal)
        } else {
            answerCard(.Hard)
        }
    }

    
//    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
//        println("began")
//    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationEditCardProperties.addObserver(self, selector: "onEditCard", object: nil)
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "onSidebarInteract", object: nil)
        
    }
    
    private func answerCard(answer: AnswerDifficulty) {
        if let card = dueCard {
            var highlightLabel: UILabel! = nil
            
            switch answer {
            case .Forgot:
                highlightLabel = leftIndicator
                card.answerCard(.Forgot)
            case .Normal:
                highlightLabel = middleIndicator
                card.answerCard(.Normal)
            case .Hard:
                highlightLabel = rightIndicator
                card.answerCard(.Hard)
            default:
                break
            }
            
            highlightLabel.hidden = false
            highlightLabel.alpha = 1
            
            UIView.animateWithDuration(0.25,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: {
                    highlightLabel.alpha = 0
                },
                completion: {
                    (_) -> () in
                    highlightLabel.hidden = true
                    self.onHighlightAnimationFinish()
            })
            
            saveContext()
        }
        
        advanceCard()
    }    
    private func onHighlightAnimationFinish() {
        updateText()
        
        if due.count == 0 {
            Globals.notificationTransitionToView.postNotification(.CardsFinished)
        }
    }
    
    func onEditCard() {
        if !view.hidden {
            edgeReveal.editCardProperties(dueCard, value: Globals.notificationEditCardProperties.value)
            
            saveContext()
        }
    }
    
    private var processUndo = false
    
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
            setVisible: {(visible: Bool, completed: Bool) -> () in
                if let card = self.dueCard {
                    self.cardPropertiesSidebar.updateContents(
                        card,
                        showUndoButton: self.undoStack.count > 0,
                        onUndoButtonTap: {
                        self.edgeReveal.animateSelf(false)
                        self.processUndo = true
                    })
                }
                self.addRemoveSidebar.hidden = !visible
                
                if !visible && self.processUndo {
                    self.processUndo = false
                    self.backTextCache = nil
                    self.onUndo()
                }
        })
        
        edgeReveal.onTap = {(open: Bool) -> () in
            if self.edgeReveal.animationState == .Closed {
                if !open && !self.isFront {
                    self.answerCard(.Hard)
                } else {
                    self.advanceCard()
                }
            }
        }
    }
    
    private func onUndo() {
//        println("undo")
        if undoStack.count > 0 {
            var remove = undoStack.removeLast()
            
            due.insert(remove, atIndex: 0)
            
//            println(managedObjectContext.undoManager.undoActionName)
            managedObjectContext.undoManager.undo()
            
            isFront = true
            updateText()
        }
    }
    
    private func onRedo() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCards()
        updateText()
    }
    
    private func fetchCards(clearUndoStack: Bool = true) {
        var fetchAheadAmount: Double = 0
        
        switch Globals.notificationTransitionToView.value {
        case .GameMode(let studyAheadAmount):
            fetchAheadAmount = studyAheadAmount
        default:
            break
        }
        
        due = managedObjectContext.fetchCardsDue(fetchAheadAmount: fetchAheadAmount).map { ($0 as Card).index }
        if clearUndoStack {
            undoStack = []
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if due.count == 0 {
            Globals.notificationTransitionToView.postNotification(.CardsFinished)
        }
    }
    
    func advanceCard() {
//        if !isFront {
//            println("\(dueCard?.kanji) dueTime = \(dueCard?.interval)")
//        }
        
        if isBack && due.count >= 1 {
            var remove = due.removeAtIndex(0)
            undoStack.append(remove)
        }
        
        if due.count == 0 {
            fetchCards(clearUndoStack: false)
        }
        
        if due.count != 0 {
            isFront = !isFront
            
//            if isBack {
//                println("\(dueCard?.kanji) dueTime = \(dueCard?.interval)")
//            }
            
            if isBack {
                if var path = dueCard?.embeddedData.soundWord {
                    playSound(filterSoundPath(path))
                }
                
                updateText()
            }
        }
    }
    
    func filterSoundPath(path: String) -> String {
        var range: NSRange = NSRange(location: 7, length: countElements(path) - 12)
        return (path as NSString).substringWithRange(range)
    }
    
    func playSound(name: String, fileType: String = "mp3", var sendEvents: Bool = true) {
        if settings.volume != 0 {
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
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        
        if var path = dueCard?.embeddedData.soundDefinition {
            if !isFront {
                playSound(filterSoundPath(path), sendEvents: false)
            }
        }
    }
    
    func onSidebarInteract() {
        edgeReveal.animateSelf(false)
    }
    
//    func onInteract(interactType: InteractType, _ card: Card) {
//        switch interactType {
//        case .Tap:
//            //            card.answerCard(.Normal)
//            break
//        case .SwipeRight:
////            println("Swiped right \(card.kanji)")
////            card.answerCard(.Hard)
//            //            due.append(due[0])
//            break
//        case .SwipeLeft:
////            println("Swiped Left \(card.kanji)")
////            card.answerCard(.Forgot)
//            //            due.append(due[0])
//            break
//        case .SwipeUp:
//            break
////            println("Swiped Up \(card.kanji)")
////            card.answerCard(.Easy)
//        case .SwipeDown:
//            break
////            println("Swipe Down \(card.kanji)")
//        }
//        advanceCard()
//        saveContext()
//    }
    
    
//    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            if !isFront {
//                if let card = dueCard {
//                    switch swipeGesture.direction {
//                        
//                    case UISwipeGestureRecognizerDirection.Right:
//                        onInteract(.SwipeRight, card)
//                        
//                    case UISwipeGestureRecognizerDirection.Down:
//                        onInteract(.SwipeDown, card)
//                        
//                    case UISwipeGestureRecognizerDirection.Up:
//                        onInteract(.SwipeUp, card)
//                        
//                    case UISwipeGestureRecognizerDirection.Left:
//                        onInteract(.SwipeLeft, card)
//                        
//                    default:
//                        break
//                    }
//                }
//            }
//        }
//    }
    
//    func setupSwipeGestures() {
////        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
////        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
////        self.view.addGestureRecognizer(swipeRight)
////        
////        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
////        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
////        self.view.addGestureRecognizer(swipeDown)
////        
////        var swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
////        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
////        self.view.addGestureRecognizer(swipeUp)
////        
////        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
////        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
////        self.view.addGestureRecognizer(swipeLeft)
    //    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}