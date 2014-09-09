import UIKit
import CoreData
import AVFoundation

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
    var audioPlayer: AVAudioPlayer?
    
    var timer: NSTimer!
    let frameRate: Double = 1.0 / 60.0
    
    let downPressInterval: Double = 2.0
    let panDistance: CGFloat = 50
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
    
    let topInset: CGFloat = 100
    var backTextCache: NSAttributedString! = nil
    var frontTextCache: NSAttributedString! = nil
    var nextFrontTextCache: NSAttributedString! = nil
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        var diff = NSDate.timeIntervalSinceReferenceDate() - flipCardTime
        
        if scrollView.contentOffset.y != topInset && diff < 0.1 {
            scrollOutputTextToInset()
        }
    }
    
//    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
//        println("touchesBegan")
//    }
    
    private func scrollOutputTextToInset() {
        outputText.setContentOffset(CGPoint(x: 0, y: topInset), animated: false)
    }
    
    var flipCardTime: NSTimeInterval = 0
    func updateText() {
        if let card = dueCard {
            if isFront {
                if frontTextCache == nil {
                    frontTextCache = card.front
                }
                kanjiView.attributedText = frontTextCache
                outputText.text = ""
                frontTextCache = nil
            }
            else {
                if backTextCache == nil {
                    backTextCache = card.back
                }
                
                kanjiView.text = ""
                outputText.attributedText = backTextCache
                outputText.textAlignment = .Center
                flipCardTime = NSDate.timeIntervalSinceReferenceDate()
                scrollOutputTextToInset()
                backTextCache = nil
            }
            kanjiView.hidden = !isFront
            kanjiView.enabled = isFront
        }
        
        if canUndo {
            leftEdgeReveal.frame.origin.x = 0
        } else {
            leftEdgeReveal.frame.origin.x = -leftEdgeReveal.frame.width
        }
    }
    
//    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
//        
//        println("touchesBegan")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEdgeReveal()
        
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
        
        outputText.decelerationRate = 0.92 //Default = 0.998
        
        var panGesture = UIPanGestureRecognizer(target: self, action: "onPan:")
        frontBlocker.addGestureRecognizer(panGesture)
        panGesture.delegate = self

//        var downGesture = UILongPressGestureRecognizer(target: self, action: "onDown:")
//        downGesture.delegate = self
//        downGesture.minimumPressDuration = 0
//        downGesture.allowableMovement = 0
//        downGesture.delaysTouchesEnded = false
//        downGesture.cancelsTouchesInView = false
//        self.outputText.addGestureRecognizer(downGesture)
        self.outputText.delegate = self
        
        var onTouchGesture = UITapGestureRecognizer(target: self, action: "onTouch:")
        onTouchGesture.delegate = self
        outputText.addGestureRecognizer(onTouchGesture)
//        onTouchGesture.requireGestureRecognizerToFail(outputText.panGestureRecognizer)
        
        var setCategoryError: NSError?
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.DuckOthers, error: &setCategoryError)
        //AVAudioSessionCategoryOptions.MixWithOthers
    }
    
    var progressBarPercent: Double {
    get {
        return (NSDate.timeIntervalSinceReferenceDate() - downBeganTime) / downPressInterval
    }
    }
    
    private func updateProgressBar() {
        if progressBar.visible {
            progressBar.progress = Float(progressBarPercent)
        }
    }
    
    func onTimerTick() {
//        println(NSDate.timeIntervalSinceReferenceDate())
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
                frontTextCache = card.front
            }
        }
        
        if  frontBlocker.visible &&
            isDown &&
            progressBarPercent > 1 {
                
            onUp()
        }//onUp frontBlocker.visible = false
        
    }
    
    func onTouch(sender: UITapGestureRecognizer) {
        
        if rightEdgeReveal.animationState != AnimationState.Closed {
            return
        }
        
//        println("onTouch")
        
        if !wasFront {
            caculateAnswer(sender)
            
            frontBlocker.visible = true
        }
    }
    
    var wasFront = false
    var downBeganTime: NSTimeInterval = 0
    var isDown = false
    @IBAction func onDown(sender: UIButton) {
        wasFront = isFront
        didPan = false
        isDown = true
        
        if isFront && rightEdgeReveal.animationState == AnimationState.Closed {
            advanceCard()
            
            downBeganTime = NSDate.timeIntervalSinceReferenceDate()
            
            progressBar.progress = 0
            progressBar.visible = true
        }

    }
    @IBAction func onBlockerUpInside(sender: UIButton) {
//        println("onBlockerUpInside")
        
        onUp()
    }
    
    func onUp() {
        isDown = false
        
        var percent = (NSDate.timeIntervalSinceReferenceDate() - downBeganTime) / downPressInterval
        
        progressBar.visible = false
        if percent < 1 && !didPan && wasFront {
            // Advance
            downBeganTime = 0
            answerCard(.Normal)
        } else {
//            println("hide blocker")
            frontBlocker.visible = false
        }
        
        wasFront = isFront
        
//        println("on up was front = \(wasFront)")
        
    }
    
    var didPan = false
    
    func onPan(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .Changed:
            let distance = sender.translationInView(view).magnitude
            
            if distance > panDistance && !didPan {
                didPan = true
                onUp()
            }

        default:
            break
        }
        //        panStart = sender.locationInView(view)
    }
    
    private func contentsUpdate(x: CGFloat) {
        outputText.frame.origin.x = x
        kanjiView.frame.origin.x = x
    }
    
//    private func sidebarSetVisiblity(visible: Bool) {
////        leftSidebar.visible = visible
////        rightSidebar.visible = visible
//    }
//    
//    private func sidebarUpdate(var x: CGFloat) {
//        
//        if x != 0 {
//            x = min(leftSidebar.frame.width, abs(x)) * sign(x)
//        }
//        
//        leftSidebar.frame.origin.x = x - leftSidebar.frame.width
//        rightSidebar.frame.origin.x = x + Globals.screenSize.width
//    }
    
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
            if let card = dueCard {
                CardPropertiesSidebar.editCardProperties(card, Globals.notificationEditCardProperties.value)
            }
            
            saveContext()
            rightEdgeReveal.animateSelf(false)
        }
    }
    
    private var processUndo: Bool = false
    private var processAdvanceCard: Bool = false
    
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
                    self.clearCaches()
                    self.onUndo()
                }
                
                if !visible && self.processAdvanceCard {
                    self.processAdvanceCard = false
                    self.isFront = false
                    self.advanceCardAndUpdateText()
                }
        })
        
        cardPropertiesSidebar.onUndoButtonTap = {
            self.rightEdgeReveal.animateSelf(false)
            self.processUndo = true
        }
        
        cardPropertiesSidebar.onPropertyButtonTap = {
            self.processAdvanceCard = true
        }
    }
    
    private func clearCaches() {
        backTextCache = nil
        frontTextCache = nil
    }
    
    private func onUndo() {
        if canUndo {
            if isBack {
                isFront = true
            } else {
                var remove = undoStack.removeLast()
                
                due.insert(remove, atIndex: 0)
                
                managedObjectContext.undoManager.undo()
                
                isFront = true
                
                redoStackCount++
            }
            
            updateText()
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
        
        clearCaches()
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
        
        soundEnabled = Globals.audioDirectoryExists
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
}