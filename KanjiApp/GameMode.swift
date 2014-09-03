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

class GameMode: CustomUIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    @IBOutlet var outputText: UITextView!
    
    var due: [NSNumber] = []
    var undoStack: [NSNumber] = []
    var redoStackCount = 0
    var isFront: Bool = true
    var isBack: Bool {
    get {
        return !isFront
    }
    }
    var audioPlayer: AVAudioPlayer!
    
    var timer: NSTimer? = nil
    let frameRate: Double = 1 / 60
    
    let downPressInterval: Double = 2.0
    
    @IBOutlet weak var leftIndicator: UILabel!
//    @IBOutlet weak var middleIndicator: UILabel!
    @IBOutlet weak var rightIndicator: UILabel!
    
    @IBOutlet weak var propertiesSidebar: UIView!
    @IBOutlet weak var kanjiView: UILabel!
        @IBOutlet weak var leftSidebar: UIButton!
    @IBOutlet weak var rightSidebar: UIButton!
    
    @IBOutlet weak var undoSidebar: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
//    override var sidebarEnabled: Bool {
//        get {
//            return false
//        }
//    }
//    let sidebarShadowOpacity: Float = 0.04
    
    var leftEdgeReveal: EdgeReveal! = nil
    var rightEdgeReveal: EdgeReveal! = nil
    
    var canUndo: Bool {
        get {
            return undoStack.count > 0
        }
    }
    
    var canRedo: Bool {
        get {
            return redoStackCount > 0
        }
    }
    

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
        
        if canUndo {
            leftEdgeReveal.frame.origin.x = 0
        } else {
            leftEdgeReveal.frame.origin.x = -leftEdgeReveal.frame.width
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEdgeReveal()
        
        leftIndicator.hidden = true
//        middleIndicator.hidden = true
        rightIndicator.hidden = true
        leftSidebar.hidden = true
        rightSidebar.hidden = true
        undoSidebar.hidden = true
        progressBar.hidden = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(frameRate, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
        
//        var onSwipeToRight = UISwipeGestureRecognizer(target: self, action: "onSwipeToRight:")
//        onSwipeToRight.delegate = self
//        onSwipeToRight.direction = .Right
//        outputText.addGestureRecognizer(onSwipeToRight)
        
//        outputText.panGestureRecognizer.delegate = self
        
        var panGesture = UIPanGestureRecognizer(target: self, action: "onPan:")
        panGesture.delegate = self
        self.outputText.addGestureRecognizer(panGesture)
        
//        println("viewDidLoad")
        var downGesture = UILongPressGestureRecognizer(target: self, action: "onDown:")
        downGesture.delegate = self
        downGesture.minimumPressDuration = 0
        self.outputText.addGestureRecognizer(downGesture)
        self.outputText.delegate = self
        
        var onTouchGesture = UITapGestureRecognizer(target: self, action: "onTouch:")
        onTouchGesture.delegate = self
        onTouchGesture.requireGestureRecognizerToFail(outputText.panGestureRecognizer)
        outputText.addGestureRecognizer(onTouchGesture)
        
        
//        kanjiView.layer.shadowColor = UIColor.blackColor().CGColor
//        kanjiView.layer.shadowOffset = CGSizeMake(2, 0)
//        kanjiView.layer.masksToBounds = false
//        kanjiView.layer.shadowRadius = 10
//        outputText.layer.shadowColor = UIColor.blackColor().CGColor
//        outputText.layer.shadowOffset = CGSizeMake(2, 0)
//        outputText.layer.masksToBounds = false
//        outputText.layer.shadowRadius = 10
        
//        kanjiView.layer.shadowColor = UIColor.blackColor().CGColor
//        kanjiView.layer.shadowOffset = CGSizeMake(2, 0)
//        kanjiView.layer.masksToBounds = false
//        self.outputText.layer.shadowOpacity = self.sidebarShadowOpacity
//        mainView.layer.shadowOpacity =
//        var onLongPress = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
//        onLongPress.delegate = self
        //        outputText.addGestureRecognizer(onLongPress)[[AVAudioSession sharedInstance] setDelegate: self];
        
//        AVAudioSession.sharedInstance().delegate
        var setCategoryError: NSError?
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &setCategoryError)
        
        
        
//        AVAudioSession.sharedInstance().setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
//        if (setCategoryError)
//        NSLog(@"Error setting category! %@", setCategoryError);
    }
    
    func onTimerTick() {
//        progressBar.visible = false
        
//        println(progressBar.visible)
        if progressBar.visible {
//            println(downBeganTime)
            var percent = (NSDate.timeIntervalSinceReferenceDate() - downBeganTime) / downPressInterval
            
            progressBar.progress = Float(percent)
        }
    }
    
//    private var lastScrollY: CGFloat? = nil
//    private var lastScrollTime: NSTimeInterval! = nil
//    private var scrollSpeed: CGFloat = 0
//    func scrollViewDidScroll(scrollView: UIScrollView!) {
//    }
////        println("scrollViewDidScroll")
//        
//        if let lastScrollY = lastScrollY {
//            var scrollY = outputText.contentOffset.y
//            var scrollTime = NSDate.timeIntervalSinceReferenceDate()
//            
//            scrollY -= lastScrollY
//            scrollTime -= lastScrollTime
//            
//            var speed = abs(scrollY / CGFloat(scrollTime) / 1000)
//            
////            if speed != 0 {
//            scrollSpeed = speed
////            }
////            scrollSpeed = 2
//            
//            //            println(scrollSpeed)
////            println("scrollSpeed = \(scrollSpeed)")
////            println("test")
//        }
//        
//        lastScrollY = outputText.contentOffset.y
//        lastScrollTime = NSDate.timeIntervalSinceReferenceDate()
////        println(scrollView.panGestureRecognizer.velocityInView(view).y)
////        println(outputText.)
//    }
    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
////        println("scrollViewDidEndDecelerating")
//        scrollSpeed = 0
//    }
    
//    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView!) {
//        println("end")
//    }
    
//    func scrollViewDidEndDragging(scrollView: UIScrollView!, willDecelerate decelerate: Bool) {
//        println("scrollViewDidEndDragging")
//    }
    
    func onTouch(sender: UITapGestureRecognizer) {
        if rightEdgeReveal.animationState != AnimationState.Closed {
            return
        }
        
        if !wasFront {
            
            //answerCard(.Normal)
            caculateAnswer(sender)
//            caculateAnswer(sender)
        }
        
//        println("touch")

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
    
//    func onLongPress(sender: UILongPressGestureRecognizer) {
//        switch sender.state {
//        case .Began:
//            if rightEdgeReveal.animationState == .Closed {
//                rightEdgeReveal.animateSelf(true)
//            }
//        default:
//            break
//        }
//    }
    
    var wasFront = false
    var downBeganTime: NSTimeInterval = 0
    func onDown(sender: UILongPressGestureRecognizer) {
        
//        let tapRadius: CGFloat = 3
//        let maxTravelled: CGFloat = 8
//        println("onDownz")
        
        var percent = (NSDate.timeIntervalSinceReferenceDate() - downBeganTime) / downPressInterval
        
//        println("\(sender.state.hashValue)")
        
        switch sender.state {
        case .Began:
//            println("Began")
            wasFront = isFront
            didPan = false
            
//            println(isFront)
            if  isFront &&
                rightEdgeReveal.animationState == AnimationState.Closed {
                advanceCard()
                    
                downBeganTime = NSDate.timeIntervalSinceReferenceDate()
//                println(downBeganTime)
                
                progressBar.visible = true
                progressBar.progress = 0
            }
            
//            UIView.animateWithDuration(interval,
//                delay: 0,
//                options: .CurveEaseOut,
//                {
//                    self.progressBar.progress = 1
//                },
            //                completion: nil)
//        case .Changed:
//            println("Changed")
//        case .Cancelled:
//            println("Cancelled")
//        case .Failed:
//            println("Failed")
//        case .Possible:
//            println("Possible")
        case .Ended:
//            println("Ended")

            progressBar.visible = false
            if percent < 1 && !didPan && wasFront {
//                println(percent)
                downBeganTime = 0
                answerCard(.Normal)
                //advanceCardAndUpdateText()
            }
        default:
            break
        }
    }
    
    var didPan = false
    func onPan(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            didPan = true
            progressBar.visible = false
        default:
            break
        }
        
//        return
//        if rightEdgeReveal.animationState != AnimationState.Closed {
//            return
//        }
//        
////        println()
//        
////        if !canUndo && !canRedo {
////            return
////        }
//        
//        let transitionThreshold: CGFloat = 32
//        var x = sender.translationInView(view).x
//        
////        if !canUndo {
////            x = min(0, x)
////        }
////        
////        if !canRedo {
////            x = max(0, x)
////        }
//        
//        x = max(0, abs(x) - 18) * sign(x)
//        x = min(abs(x), leftSidebar.frame.width) * sign(x)
//        
//        contentsUpdate(x)
//        sidebarUpdate(x)
//        
//        switch sender.state {
//        case .Began:
//            sidebarSetVisiblity(true)
//        case .Ended:
//            var contentsTargetX: CGFloat = 0
//            var active = false
//            var isRight = false
//            
//            if x > transitionThreshold {
////                contentsTargetX = Globals.screenSize.width
//                active = true
//            } else if x < -transitionThreshold {
////                contentsTargetX = -Globals.screenSize.width
//                active = true
//                isRight = true
//            }
//            
////            println(active)
//            
//            UIView.animateWithDuration(0.16,
//                delay: 0,
//                options: .CurveEaseOut,
//                {
//                    self.sidebarUpdate(0)
////                    if active {
////                        self.contentsUpdate(contentsTargetX)
////                    } else {
////                    }
//                    self.contentsUpdate(0)
//                },
//                completion: { (_) -> () in
//                    
//                    self.sidebarSetVisiblity(false)
//                    
//                    if active {
//                        if isRight {
//                            self.answerCard(.Hard)
//                        } else {
//                            self.answerCard(.Forgot)
//                        }
////                        if isRedo {
////                            self.onRedo()
////                        } else {
////                            self.onUndo()
////                        }
//                        
//                        self.contentsUpdate(-contentsTargetX)
//                        UIView.animateWithDuration(0.16,
//                            delay: 0,
//                            options: .CurveEaseOut,
//                            {
//                                self.contentsUpdate(0)
//    //                            self.contentsAlpha(1)
//                            },
//                            completion: nil
//                        )
//                    }
//
////                self.contentsUpdate(0)
//            })
//
//        default:
//            break
//        }
    }
    
//    private func contentsSetVisiblity(visible: Bool) {
//        
//    }
    //
//    private func contentsAlpha(value: CGFloat) {
//        outputText.alpha = value
//        kanjiView.alpha = value
//    }
    
    private func contentsUpdate(x: CGFloat) {
        outputText.frame.origin.x = x
        kanjiView.frame.origin.x = x
        
//        var alpha: CGFloat = 1 - abs(x / Globals.screenSize.width)//1 - max(0, abs(x) - leftSidebar.frame.width) / (Globals.screenSize.width - leftSidebar.frame.width)
//        alpha = alpha * alpha
//        
//        contentsAlpha(alpha)
    }
    
    private func sidebarSetVisiblity(visible: Bool) {
        leftSidebar.visible = visible
        rightSidebar.visible = visible
    }
    
    private func sidebarUpdate(var x: CGFloat) {
        
        if x != 0 {
            x = min(leftSidebar.frame.width, abs(x)) * sign(x)
        }
        
        leftSidebar.frame.origin.x = x - leftSidebar.frame.width
        rightSidebar.frame.origin.x = x + Globals.screenSize.width
    }
    
    private func caculateAnswer(sender: UIGestureRecognizer) {
        var x = sender.locationInView(self.view).x / Globals.screenSize.width
        x *= 2
        
        if x >= 0 && x < 1 {
            answerCard(.Forgot)
        } else {
            answerCard(.Hard)
        }
    }

    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationEditCardProperties.addObserver(self, selector: "onEditCard", object: nil)
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "onSidebarInteract", object: nil)
        
    }
    
    private func answerCard(answer: AnswerDifficulty) {
        if let card = dueCard {
            var highlightLabel: UILabel? = nil
            
            switch answer {
            case .Forgot:
                highlightLabel = leftIndicator
                card.answerCard(.Forgot)
            case .Normal:
//                highlightLabel = middleIndicator
                card.answerCard(.Normal)
            case .Hard:
                highlightLabel = rightIndicator
                card.answerCard(.Hard)
            default:
                break
            }
            
            if let highlightLabel = highlightLabel {
                highlightLabel.hidden = false
                highlightLabel.alpha = 1
                
                UIView.animateWithDuration(0.5,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        highlightLabel.alpha = 0
                    },
                    completion: {
                        (_) -> () in
                        highlightLabel.hidden = true
                        self.advanceCardAndUpdateText()
                })
            } else {
                self.advanceCardAndUpdateText()
            }
            
            saveContext()
        }
        
    }    
    private func advanceCardAndUpdateText() {
        advanceCard()
        updateText()
        
        if due.count == 0 {
            Globals.notificationTransitionToView.postNotification(.CardsFinished)
        }
    }
    
    func onEditCard() {
        if !view.hidden {
            rightEdgeReveal.editCardProperties(dueCard, value: Globals.notificationEditCardProperties.value)
            
            saveContext()
        }
    }
    
    private var processUndo: Bool = false
    private var processAdvanceCard: Bool = false
    
    private func setupEdgeReveal() {
        
        leftEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Left,
            maxOffset: undoSidebar.frame.width,
            swipeAreaWidth: 0,
            onUpdate: {(offset: CGFloat) -> () in
                
                self.undoSidebar.frame.origin.x = offset - self.undoSidebar.frame.width
                self.outputText.frame.origin.x = offset
                self.kanjiView.frame.origin.x = offset
            },
            setVisible: {(visible: Bool, completed: Bool) -> () in
                self.undoSidebar.visible = visible
                
                if !visible && self.processUndo {
                    self.processUndo = false
                    self.onUndo()
                }
                
            })
        
        leftEdgeReveal.allowOpen = false
        
        leftEdgeReveal.onOpenClose = {(shouldOpen: Bool) -> () in
            if shouldOpen {
                self.processUndo = true
            }
        }
        
        rightEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Right,
            //swipeAreaWidth: 0,
            onUpdate: {(offset: CGFloat) -> () in
                self.outputText.frame.origin.x = -offset
                self.propertiesSidebar.frame.origin.x = Globals.screenSize.width - offset
                self.kanjiView.frame.origin.x = -offset
                self.cardPropertiesSidebar.animate(offset)
            },
            setVisible: {(visible: Bool, completed: Bool) -> () in
                if let card = self.dueCard {
                    self.cardPropertiesSidebar.updateContents(
                        card,
                        showUndoButton: self.canUndo)
                }
                self.propertiesSidebar.hidden = !visible
                
                if !visible && self.processUndo {
                    self.processUndo = false
                    self.backTextCache = nil
                    self.onUndo()
                }
//                println("processAdvanceCard \(self.processAdvanceCard)")
                
                if !visible && self.processAdvanceCard {
                    self.processAdvanceCard = false
                    self.advanceCardAndUpdateText()
                }
                
//                self.setSelfShadow(visible)
//                RootContainer.instance.setSelfShadow(visible)
        })
        
        cardPropertiesSidebar.onUndoButtonTap = {
            self.rightEdgeReveal.animateSelf(false)
            self.processUndo = true
        }
        
        cardPropertiesSidebar.onAddButtonTap = {
            self.processAdvanceCard = true
        }
        
        cardPropertiesSidebar.onKnownButtonTap = {
            self.processAdvanceCard = true
        }
        
        cardPropertiesSidebar.onRemoveButtonTap = {
            self.processAdvanceCard = true
        }
        
//        rightEdgeReveal.onTap = {(open: Bool) -> () in
//            if self.rightEdgeReveal.animationState == .Closed {
//                if !open && !self.isFront {
//                    self.answerCard(.Hard)
//                } else {
//                    self.advanceCard()
//                }
//            }
//        }
    }
    
    
//    func setSelfShadow(visible: Bool) {
//        if visible {
//            self.outputText.layer.shadowOpacity = self.sidebarShadowOpacity
//            self.kanjiView.layer.shadowOpacity = self.sidebarShadowOpacity
//        } else {
//            self.outputText.layer.shadowOpacity = 0
//            self.kanjiView.layer.shadowOpacity = 0
//        }
//    }
    
    private func onUndo() {
        if canUndo {
            var remove = undoStack.removeLast()
            
            due.insert(remove, atIndex: 0)
            
            managedObjectContext.undoManager.undo()
            
            isFront = true
            updateText()
            
            redoStackCount++
        }
    }
    
    private func onRedo() {
        if due.count > 0 && canRedo {
            var remove = due.removeAtIndex(0)
            
            undoStack.insert(remove, atIndex: undoStack.count)
            
            managedObjectContext.undoManager.redo()
            
            isFront = true
            updateText()
            
            redoStackCount--
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCards()
        updateText()
    }
    
    private func fetchCards(clearUndoStack: Bool = true) {
        redoStackCount = 0
        
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
//                    playSound("invalidPath.mp3")
                    playSound(filterSoundPath(path))
                }
                
                updateText()
            }
        }
    }
    
    func filterSoundPath(path: String) -> String {
        println(settings.volume)
        
        println(Globals.audioDirectoryPath)
        println(path)
        var range: NSRange = NSRange(location: 7, length: countElements(path) - 12)
        return (path as NSString).substringWithRange(range)
    }
    
    func playSound(name: String, fileType: String = "mp3", var sendEvents: Bool = true) {
        println("playSound")
        println(name)
        if settings.volume.doubleValue != 0 {
            println("volume not zero")
            var resourcePath = Globals.audioDirectoryPath.stringByAppendingPathComponent(name)//NSBundle.mainBundle().pathForResource(name, ofType: fileType)
            resourcePath = "\(resourcePath).mp3"
            
            println("Unused old bundle path = \(NSBundle.mainBundle().pathForResource(name, ofType: fileType))")
            
            println(resourcePath)
            
            if let resourcePath = resourcePath {
                println("URL = \(resourcePath)")
                var sound = NSURL(fileURLWithPath: resourcePath)
                
                let filemgr = NSFileManager.defaultManager()
                println("file exists = \(filemgr.fileExistsAtPath(resourcePath))")
//                println("file does not exist (shoudl be false) = \(filemgr.fileExistsAtPath("test"))
                println("sound = \(sound)")
                
//                println("file exists = \(.length))")
                var data = NSData(contentsOfFile: resourcePath)
                
                var error:NSError?
                audioPlayer = AVAudioPlayer(data: data, error: &error)
                audioPlayer.volume = 1
                
                println("audioPlayer.volume = \(audioPlayer.volume)")
                
//                audioPlayer.
                println("error = \(error)")
                if sendEvents {
                    audioPlayer.delegate = self
                }
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        
        println("audioPlayerDidFinishPlaying \(flag)")
        if var path = dueCard?.embeddedData.soundDefinition {
            if !isFront {
                playSound(filterSoundPath(path), sendEvents: false)
            }
        }
    }
    
    func onSidebarInteract() {
        rightEdgeReveal.animateSelf(false)
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