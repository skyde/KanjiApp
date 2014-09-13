import UIKit
import CoreData
import AVFoundation

enum GameTutorialState {
    case Disabled
    case LongPressFront
    case LongPressBack
    case LongPressMistake
    case CardBackExplain
    case AutoAdvanceFront
    case AutoAdvanceBack
    case AutoAdvanceMistake
    case Finished
    case PostFinished
    
    var enabled: Bool {
    get {
        return !(self == .Disabled)
    }
    }
}

class GameMode: CustomUIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    @IBOutlet var outputText: UITextView!
    
    var due: [NSNumber] = []
    var undoStack: [NSNumber] = []
//    var redoStackCount = 0
    var isFront: Bool = true
    var isBack: Bool {
    get {
        return !isFront
    }
    }
    var audioPlayer: AVAudioPlayer?
    
    var timer: NSTimer!
    let frameRate: Double = 1.0 / 60.0
    
    var baseLongPressTime: Double!
    var longPressTime: Double = 1.5
    var tutorialLongPressTime: Double = 2.5
    let maxPan: CGFloat = 35
    @IBOutlet weak var leftIndicator: UILabel!
    @IBOutlet weak var rightIndicator: UILabel!
    
    @IBOutlet weak var propertiesSidebar: UIView!
    @IBOutlet weak var kanjiView: UILabel!
//    @IBOutlet weak var leftSidebar: UIButton!
//    @IBOutlet weak var rightSidebar: UIButton!
    
//    @IBOutlet weak var undoSidebar: UIButton!
    @IBOutlet weak var frontBlocker: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var leftEdgeReveal: EdgeReveal! = nil
    var rightEdgeReveal: EdgeReveal! = nil
    
    var soundEnabled = true
    
    var canUndo: Bool {
        get {
            return undoStack.count > 0 || isBack
        }
    }
    
    var tutorialState: GameTutorialState = .Disabled
    
    @IBOutlet weak var tutorialHoldToViewBack: UIVisualEffectView!
    @IBOutlet weak var tutorialHoldUntilTimerReachesEnd: UIVisualEffectView!
    @IBOutlet weak var tutorialHoldUntilTimerReachesEndMistake: UIVisualEffectView!
    @IBOutlet weak var tutorialCardBackExplain: UIVisualEffectView!
    @IBOutlet weak var tutorialPressReleaseQuicklyFront: UIVisualEffectView!
    @IBOutlet weak var tutorialPressReleaseQuicklyBack: UIVisualEffectView!
    @IBOutlet weak var tutorialPressReleaseQuicklyFrontMistake: UIVisualEffectView!
    @IBOutlet weak var tutorialFinished: UIVisualEffectView!
    
    @IBOutlet weak var postTutorialFinished: UIVisualEffectView!
//    @IBOutlet weak var tutorialCardExplain2: UIVisualEffectView!
    @IBOutlet weak var tutorialButton: UIButton!
    
    var dueCard: Card? {
        get {
            if due.count > 0 {
                return managedObjectContext.fetchCardByIndex(due[0])
            }
            return nil
        }
    }
    
    var nextCard: Card? {
        get {
            if due.count > 1 {
                return managedObjectContext.fetchCardByIndex(due[1])
            }
            return nil
        }
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    var cardPropertiesSidebar: CardPropertiesSidebar {
        return self.childViewControllers[0] as CardPropertiesSidebar
    }
    
    let topInset: CGFloat = 20
    var backTextCache: NSAttributedString! = nil
    var frontTextCache: UIFont! = nil
    var nextFrontTextCache: NSAttributedString! = nil
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if let dueCard = dueCard {
            var diff = NSDate.timeIntervalSinceReferenceDate() - flipCardTime
            
            if scrollView.contentOffset.y != dueCard.backScrollUpKanjiTextHeight + topInset && diff < 0.1 {
                scrollOutputTextToInset()
            }
        }
    }
    
    private func scrollOutputTextToInset() {
        if let dueCard = dueCard {
            outputText.setContentOffset(CGPoint(x: 0, y: dueCard.backScrollUpKanjiTextHeight + topInset), animated: false)
        }
    }
    
    private func tryGenerateFrontTextCache(card: Card) {
        if frontTextCache == nil {
//            println("Globals.screenOrientationVertical = \(Globals.screenOrientationVertical)")
            
            frontTextCache = card.frontFont
        }
    }
    
    var flipCardTime: NSTimeInterval = 0
    func updateText(invalidateCaches: Bool = false) {
        frontBlocker.visible = isFront
        kanjiView.visible = isFront
        outputText.visible = isBack
        
        if invalidateCaches {
            backTextCache = nil
            frontTextCache = nil
        }
        
        if let card = dueCard {
            if isFront {
                tryGenerateFrontTextCache(card)
                kanjiView.text = card.frontText
                kanjiView.font = frontTextCache
                frontTextCache = nil
            }
            else {
                if backTextCache == nil {
                    backTextCache = card.back
                }
                
                outputText.attributedText = backTextCache
                flipCardTime = NSDate.timeIntervalSinceReferenceDate()
                scrollOutputTextToInset()
                backTextCache = nil
            }
//            kanjiView.enabled = isFront
        }
        
//        if canUndo {
//            leftEdgeReveal.frame.origin.x = 0
//        } else {
//            leftEdgeReveal.frame.origin.x = -leftEdgeReveal.frame.width
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseLongPressTime = longPressTime
        setupEdgeReveal()
        
//        tutorialButton.butt = .UIButtonTypeDetail
        
//        kanjiView.contenth
        
        leftIndicator.hidden = true
        rightIndicator.hidden = true
//        leftSidebar.hidden = true
//        rightSidebar.hidden = true
//        undoSidebar.hidden = true
        progressBar.hidden = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(frameRate, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
//        println(timer.tolerance)
//        println(frameRate)
        timer.tolerance = frameRate * 0.1
        self.outputText.delegate = self
        
        outputText.decelerationRate = 0.92 //Default = 0.998
        
        var panGesture = UIPanGestureRecognizer(target: self, action: "onPan:")
        frontBlocker.addGestureRecognizer(panGesture)
        panGesture.delegate = self

        var downGesture = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
        downGesture.delegate = self
        downGesture.minimumPressDuration = 0
        frontBlocker.addGestureRecognizer(downGesture)
        
        var onTouchGesture = UITapGestureRecognizer(target: self, action: "onTouch:")
        onTouchGesture.delegate = self
        outputText.addGestureRecognizer(onTouchGesture)
        
        var setCategoryError: NSError?
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.DuckOthers, error: &setCategoryError)
        //AVAudioSessionCategoryOptions.MixWithOthers
    }
    
    func onLongPress(sender: UILongPressGestureRecognizer) {
        if tutorialState == .Finished {
            switch sender.state {
            case .Began:
                didPan = true
            case .Ended:
                didPan = false
                tutorialState = .PostFinished
                updateTutorialDisplay(forceUpdate: true)
            default:
                break
            }
            return
        } else if tutorialState == .PostFinished {
            switch sender.state {
            case .Began:
                didPan = true
                postTutorialFinished.alpha = 1
                UIView.animateWithDuration(1.0,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    {
                        self.postTutorialFinished.alpha = 0
                    },
                    completion: { (_) in
                        self.postTutorialFinished.hidden = true
                        self.postTutorialFinished.alpha = 1
                })
            case .Ended:
                didPan = false
                tutorialState = .Disabled
                longPressTime = baseLongPressTime
                
                settings.seenTutorial = true
                saveContext()
//                updateTutorialDisplay(forceUpdate: true)
            default:
                break
            }
            return
        }
        
        switch sender.state {
        case .Began:
            wasFront = isFront
            didPan = false
            
            if isFront && rightEdgeReveal.animationState == AnimationState.Closed {
                advanceCard()
                
                downTime = NSDate.timeIntervalSinceReferenceDate()
                
                progressBar.progress = 0
                progressBar.visible = true
            }

        case .Ended:
            onUp()
            
        default:
            break
        }
    }
    
    var progressBarPercent: Double {
    get {
        return (NSDate.timeIntervalSinceReferenceDate() - downTime) / longPressTime
    }
    }
    
    private func updateProgressBar() {
        if progressBar.visible {
            progressBar.progress = Float(progressBarPercent)
            
            if progressBarPercent >= 1 {
                progressBar.visible = false
                
                onUp()
            }
        }
    }
    
    func onTimerTick() {
        updateProgressBar()
        
        if isFront {
            if backTextCache == nil {
                if let card = dueCard {
                    backTextCache = card.back
                }
            }
        }
        if frontTextCache == nil {
            if let card = nextCard {
                tryGenerateFrontTextCache(card)
            }
        }
    }
    
    func onTouch(sender: UITapGestureRecognizer) {
        if rightEdgeReveal.animationState != AnimationState.Closed {
            return
        }
        
        if !wasFront {
            caculateAnswer(sender)
        }
    }
    
    var wasFront = false
    var downTime: NSTimeInterval = 0
    func onUp() {
        
        var percent = (NSDate.timeIntervalSinceReferenceDate() - downTime) / longPressTime
        
        var autoAdvanced = false
        
        progressBar.visible = false
        if percent < 1 && !didPan && wasFront {
            downTime = 0
            answerCard(.Normal)
            
            autoAdvanced = true
        }
        
        updateTutorialOnUp(autoAdvanced)
//        else {
//            if  tutorialState == .HoldUntilTimerReachesEnd ||
//                tutorialState == .HoldUntilTimerReachesEndMistake {
//                tutorialState = .CardBackExplain
//                updateTutorialDisplay()
//            }
//        }
//        else {
//            frontBlocker.visible = false
//        }
        
        wasFront = isFront
    }
    
    var didPan = false
    var pan: (start: CGPoint, distance: CGFloat)?
    func onPan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            pan = (sender.locationInView(view), 0)
        case .Changed:
            if let pan = pan {
                var location = sender.locationInView(view)
                var distance = distanceAmount(pan.start, location)
                
                self.pan = (location, pan.distance + distance)
                
                if pan.distance > maxPan && !didPan {
                    didPan = true
                    onUp()
                }
            }
        case .Ended:
            pan = nil

        default:
            break
        }
    }
    
    private func contentsUpdate(x: CGFloat) {
        outputText.frame.origin.x = x
        kanjiView.frame.origin.x = x
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
                        self.advanceCard()
                })
            } else {
                self.advanceCard()
            }
            
            saveContext()
        }
        
    }    
//    private func advanceCardAndUpdateText() {
//        advanceCard()
//        updateText()
//        
//    }
    
    func onEditCard() {
        if !view.hidden {
            if let card = dueCard {
                CardPropertiesSidebar.editCardProperties(card, Globals.notificationEditCardProperties.value)
            }
            
            saveContext()
            rightEdgeReveal.animateSelf(false)
        }
    }
    
    private var processUndo: Bool = false
    private var processAdvance: Bool = false
    
    private func setupEdgeReveal() {
        
        leftEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Left,
            maxOffset: { return 100
//                return self.undoSidebar.frame.width
            },
            swipeAreaWidth: 0,
            onUpdate: {(offset: CGFloat) -> () in
                
//                self.undoSidebar.frame.origin.x = offset - self.undoSidebar.frame.width
                self.outputText.frame.origin.x = offset
                self.kanjiView.frame.origin.x = offset
            },
            setVisible: {(visible: Bool, completed: Bool) -> () in
//                self.undoSidebar.visible = visible
                
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
            animationTime: 0.1,
            swipeAreaWidth: 20,
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
//                    self.invalidateCaches()
                    self.onUndo()
                }
                
                if !visible && self.processAdvance {
                    self.processAdvance = false
                    self.isFront = false
//                    self.frontBlocker.visible = true
                    self.advanceCard()
                }
        })
        
//        rightEdgeReveal.onTap = { (open) in println("ontap")asdd }
        
        cardPropertiesSidebar.onUndoButtonTap = {
            self.rightEdgeReveal.animateSelf(false)
            self.processUndo = true
        }
        
        cardPropertiesSidebar.onPropertyButtonTap = {
            self.processAdvance = true
        }
    }
    
//    private func invalidateCaches() {
//    }
    
    private func onUndo() {
        if canUndo {
            if isBack {
                isFront = true
            } else {
                var remove = undoStack.removeLast()
                
                due.insert(remove, atIndex: 0)
                
                managedObjectContext.undoManager.undo()
                
                isFront = true
                
//                redoStackCount++
            }
            
            updateText(invalidateCaches: true)
        }
        
//        self.frontBlocker.visible = true
    }
    
//    private func onRedo() {
//        if due.count > 0 && canRedo {
//            var remove = due.removeAtIndex(0)
//            
//            undoStack.insert(remove, atIndex: undoStack.count)
//            
//            managedObjectContext.undoManager.redo()
//            
//            isFront = true
//            updateText()
//            
//            redoStackCount--
//        }
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        invalidateCaches()
        fetchCards()
        updateText(invalidateCaches: true)
//        setupTutorial()
    }
    
    private func setupTutorial(enabled: Bool) {
        // TODO: setup from start tutorial button press
//        tutorialState = .LongPressFront
//        
//        if tutorialState != .Disabled {
//            tutorialState = .LongPressFront
//        }
//        
        tutorialState = enabled ? .LongPressFront : .Disabled
        longPressTime = enabled ? tutorialLongPressTime : baseLongPressTime
        
        updateTutorialDisplay(forceUpdate: true)
    }
    
    private func updateTutorialDisplay(forceUpdate: Bool = false) {
        if tutorialState == .Disabled && !forceUpdate {
            return
        }
        
        tutorialHoldToViewBack.visible = tutorialState == .LongPressFront
        tutorialHoldUntilTimerReachesEnd.visible = tutorialState == .LongPressBack
        tutorialHoldUntilTimerReachesEndMistake.visible = tutorialState == .LongPressMistake
        tutorialCardBackExplain.visible = tutorialState == .CardBackExplain
//        tutorialCardExplain2.visible = tutorialState == .CardBackExplain
        tutorialPressReleaseQuicklyFront.visible = tutorialState == .AutoAdvanceFront
        tutorialPressReleaseQuicklyBack.visible = tutorialState == .AutoAdvanceBack
        tutorialPressReleaseQuicklyFrontMistake.visible = tutorialState == .AutoAdvanceMistake
        tutorialFinished.visible = tutorialState == .Finished
        postTutorialFinished.visible = tutorialState == .PostFinished
    }
    
    private func fetchCards(clearUndoStack: Bool = true) {
//        redoStackCount = 0
        
        var fetchAheadAmount: Double = 0
        
        switch Globals.notificationTransitionToView.value {
        case .GameMode(let studyAheadAmount, let runTutorial):
            fetchAheadAmount = studyAheadAmount
            
            if !settings.seenTutorial {
                setupTutorial(true)
            } else {
                setupTutorial(runTutorial)
            }
            
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
        
        soundEnabled = Globals.audioDirectoryExists
    }
    
//    if tutorialState != .Disabled {
//    tutorialState = .HoldToViewBack
//    }
//    
//    tutorialHoldToViewBack.visible = tutorialState != .HoldToViewBack ? true : false
//    tutorialHoldUntilTimerReachesEnd.visible = false
//    tutorialHoldUntilTimerReachesEndMistake.visible = false
//    tutorialCardBackExplain.visible = false
    
    private func updateTutorialOnUp(autoAdvanced: Bool) {
        
//        println("updateTutorialOnUp, autoAdvanced = \(autoAdvanced), \(tutorialState.hashValue)")
//        println("updateTutorialOnUp, autoAdvanced = \(autoAdvanced)")
        
        switch tutorialState {
        case .LongPressBack:
            if autoAdvanced {
                tutorialState = .LongPressMistake
            } else {
                tutorialState = .CardBackExplain
            }
        case .AutoAdvanceBack:
            if !autoAdvanced {
                tutorialState = .AutoAdvanceMistake
            } else {
                tutorialState = .Finished
            }
        default:
            break
        }
        
        updateTutorialDisplay()
    }
    
    private func stepTutorial() {
        
        if isBack {
            switch tutorialState {
            case .LongPressFront:
                tutorialState = .LongPressBack
            case .LongPressMistake:
                tutorialState = .LongPressBack
                
            case .AutoAdvanceFront:
                tutorialState = .AutoAdvanceBack
            case .AutoAdvanceMistake:
                tutorialState = .AutoAdvanceBack
            default:
                break
            }
        } else {
            switch tutorialState {
            case .CardBackExplain:
                tutorialState = .AutoAdvanceFront
            case .AutoAdvanceMistake:
                tutorialState = .AutoAdvanceFront
            default:
                break
            }
        }
        
        updateTutorialDisplay()
    }
    
    func advanceCard() {
        if isBack && due.count >= 1 {
            var remove = due.removeAtIndex(0)
            
            undoStack.append(remove)
            
            if tutorialState != .Disabled {
                due.append(remove)
            }
        }
        
        isFront = !isFront
        
        stepTutorial()
        
        if due.count == 0 {
            fetchCards(clearUndoStack: false)
        }
        
        if due.count > 0 {
            if isBack {
                if var path = dueCard?.embeddedData.soundWord {
                    playSound(filterSoundPath(path))
                }
            }
            
            updateText()
        }
        
        if due.count == 0 {
            Globals.notificationTransitionToView.postNotification(.CardsFinished)
        }
    }
    
    func filterSoundPath(path: String) -> String {
        var range: NSRange = NSRange(location: 7, length: countElements(path) - 12)
        return (path as NSString).substringWithRange(range)
    }
    
    func playSound(name: String, fileType: String = "mp3", var sendEvents: Bool = true) {
        if !soundEnabled {
            return
        }
        
        if settings.volume.doubleValue != 0 {
            var resourcePath = Globals.audioDirectoryPath.stringByAppendingPathComponent(name)
            resourcePath = "\(resourcePath).mp3"
            
            if let resourcePath = resourcePath {
                var url = NSURL(fileURLWithPath: resourcePath)
                                var error:NSError?
                audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
                
                if let audioPlayer = audioPlayer {
                    audioPlayer.volume = Float(settings.volume.doubleValue)
                    
                    if sendEvents {
                        audioPlayer.delegate = self
                    }
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                }
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
        rightEdgeReveal.animateSelf(false)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        invalidateCaches()
        updateText(invalidateCaches: true)
        rightEdgeReveal.animateSelf(false, forceAnimation: true)
//        updateDefinitionViewConstraints()
//        view.setNeedsLayout()
//        DefinitionPopover.instance.view.setNeedsLayout()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    @IBAction func tutorialButtonTap(sender: AnyObject) {
        
        if tutorialState == .Disabled {
            Globals.notificationTransitionToView.postNotification(.GameMode(studyAheadAmount: 0, runTutorial: true))
        }
    }
}