import Foundation
import UIKit
import QuartzCore

var rootContainerInstance: RootContainer? = nil

class RootContainer: CustomUIViewController {
    
    class var instance: RootContainer {
        get { return rootContainerInstance! }
    }
    var swipeFromLeftArea: UIButton! = nil
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var definitionOverlay: UIView!
//    @IBOutlet weak var blurImage: UIImageView!
    
    var sidebarButtonBaseX: CGFloat = 13
    var swipeFromLeftAreaBaseWidth: CGFloat = 0
    var statusBarHidden = false
    let popoverAnimationSpeed = 0.17 //.22
    let sidebarEasing = UIViewAnimationOptions.CurveEaseOut
    let blurEasing = UIViewAnimationOptions.CurveEaseOut
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootContainerInstance = self
        
        swipeFromLeftArea = UIButton(frame: CGRectMake(0, 0, sidebarButtonBaseX, Globals.screenSize.height))
//        swipeFromLeftArea.backgroundColor = UIColor.redColor()
        view.addSubview(swipeFromLeftArea)
        
        view.bringSubviewToFront(sidebarButton)
        view.bringSubviewToFront(backgroundImage)
        view.bringSubviewToFront(definitionOverlay)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.sendSubviewToBack(mainView)
        self.view.sendSubviewToBack(sidebar)
        
        sidebarButtonBaseX = sidebarButton.frame.origin.x
        swipeFromLeftAreaBaseWidth = swipeFromLeftArea.frame.width
        
        var gesture = UIPanGestureRecognizer(target: self, action: "respondToFromLeftSwipeGesture:")
        swipeFromLeftArea.addGestureRecognizer(gesture)
        
        var tap = UITapGestureRecognizer(target: self, action: "respondToFromLeftSwipeTap:")
        swipeFromLeftArea.addGestureRecognizer(tap)
    }
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        var open = mainView.frame.origin.x == 0
        
//        if Globals.notificationShowDefinition.value != "" {
//            Globals.notificationShowDefinition.postNotification("")
//        }
        
        Globals.notificationSidebarInteract.postNotification(open)
        
        animateSelf(open)
    }
    
    private func animateSelf(open: Bool) {
//        let xMove: CGFloat =  // 272
//        println()
        
        if open {
            sidebar.hidden = false
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: 0,
                options: sidebarEasing,
                {
                    self.definitionOverlay.frame.origin.x = self.sidebar.frame.width
                    self.backgroundImage.frame.origin.x = self.sidebar.frame.width
                    self.mainView.frame.origin.x = self.sidebar.frame.width
                    self.sidebarButton.frame.origin.x = self.sidebarButtonBaseX + self.sidebar.frame.width
    //                    print(xMove)
    //                self.swipeFromLeftArea.frame.origin.x = xMove
    //                self.swipeFromLeftArea.frame.size.width = 100
                    self.swipeFromLeftArea.frame = CGRectMake(
                        self.sidebar.frame.width,
                        self.swipeFromLeftArea.frame.origin.y,
                        Globals.screenSize.width - self.sidebar.frame.width,
                        self.swipeFromLeftArea.frame.height)
                },
                nil)
        } else {
            UIView.animateWithDuration(popoverAnimationSpeed,
            delay: 0,
            options: sidebarEasing,
                {
                    self.definitionOverlay.frame.origin.x = 0
                    self.backgroundImage.frame.origin.x = 0
                    self.mainView.frame.origin.x = 0
                    self.sidebarButton.frame.origin.x = self.sidebarButtonBaseX
                    self.swipeFromLeftArea.frame = CGRectMake(
                    0,
                    self.swipeFromLeftArea.frame.origin.y,
                    self.swipeFromLeftAreaBaseWidth,
                    self.swipeFromLeftArea.frame.height)
                },
                completion: { (_) -> Void in if self.mainView.layer.presentationLayer().frame.origin.x == 0 { self.sidebar.hidden = true } })
        }
    }

    required init(coder aDecoder: NSCoder!) {
        
        super.init(coder: aDecoder)
    }

    override func onTransitionToView() {
        super.onTransitionToView()
        
        if Globals.notificationShowDefinition.value != "" {
            Globals.notificationShowDefinition.postNotification("")
        }
        
        animateSelf(false)
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func respondToFromLeftSwipeTap(gesture: UITapGestureRecognizer) {

        if mainView.frame.origin.x != 0 {
            animateSelf(false)
        }
    }
    
    func respondToFromLeftSwipeGesture(gesture: UIPanGestureRecognizer) {

        var x = gesture.locationInView(self.view).x
        x = max(0, x)
        x = min(x, sidebar.frame.width)
        
        sidebar.hidden = x == 0
        
        self.definitionOverlay.frame.origin.x = x
        self.backgroundImage.frame.origin.x = x
        mainView.frame.origin.x = x
        sidebarButton.frame.origin.x = sidebarButtonBaseX + x
        swipeFromLeftArea.frame.origin.x = x
        
        let transitionThreshold: CGFloat = 30
        
        switch gesture.state {
        case .Began:
            Globals.notificationSidebarInteract.postNotification(!(x == 0))
        case .Ended:
            var xDelta = gesture.translationInView(self.view).x
            if xDelta > transitionThreshold {
                animateSelf(true)
            } else if xDelta < transitionThreshold {
                animateSelf(false)
            } else if xDelta < 0 {
                animateSelf(true)
            }
            else {
                animateSelf(false)
            }
        default:
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        var orientationPass = true
        switch UIDevice.currentDevice().orientation {
        case .LandscapeLeft :
            orientationPass = false
        case .LandscapeRight :
            orientationPass = false
        default:
            break
        }
        
        return View.GameMode(studyAheadAmount: 0).description() == Globals.notificationTransitionToView.value.description() ||
            !orientationPass
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        definitionOverlay.hidden = true
        sidebar.hidden = true
        backgroundImage.hidden = true
//        blurImage.hidden = true
//        blurImage.alpha = 0
    }
    
    
    func onNotificationShowDefinition() {
//        var definition = .getObject(notification)
//        println(container)
//        var definition =
        
        var animationSpeed: Double = 4
        
        if Globals.notificationShowDefinition.value == "" {
            Globals.notificationShowDefinition.value = "animating"
//            self.mainView.hidden = false
//            self.blurImage.opaque = false
            
            self.mainView.hidden = false
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: blurEasing,
                animations: {
                    self.definitionOverlay.frame.origin.x = Globals.screenSize.width
                    //self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height)
                    //                    self.mainView.alpha = 1
//                    self.definitionOverlay.alpha = 0
                    self.backgroundImage.alpha = 0
//                    self.blurImage.alpha = 0
                },
                completion: {
                (_) -> () in
                    self.definitionOverlay.hidden = true
//                    self.blurImage.hidden = true
                    Globals.notificationShowDefinition.value = ""
                    self.backgroundImage.hidden = true
                })
        } else {
            backgroundImage.hidden = false
            caculateBlur()
            definitionOverlay.hidden = false
            //self.definitionOverlay.alpha = 0
            backgroundImage.alpha = 0
//            self.mainView.alpha = 1
//            blurImage.hidden = false
            
            self.definitionOverlay.frame.origin.x = Globals.screenSize.width//CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height)
            
//            self.definitionOverlay.alpha = 1
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: 0,
                options: blurEasing,
                animations: {
//                    self.definitionOverlay.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height)
                    //                    self.blurImage.alpha = 1
//                    self.mainView.alpha = 0
                    self.definitionOverlay.frame.origin.x = 0
                    self.backgroundImage.alpha = 1
                    //self.definitionOverlay.alpha = 1
                },
                completion: {
                    (_) -> () in
//                    self.definitionOverlay.alpha = 1
//                    self.definitionOverlay.alpha = 1
                    
                    self.mainView.hidden = true
                    
//                    self.blurImage.opaque = true
                })
        }
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onNotificationShowDefinition")
        
        Globals.notificationAddWordsFromList.addObserver(self, selector: "onAddWordsFromList")
        
//        NSNotificationCenter.defaultCenter().ad
    }
    
    func caculateBlur() {
        let scale: CGFloat = 0.125
        var inputRadius:CGFloat = 20
        
        inputRadius *= scale
        let ciContext = CIContext(options: nil)
        var size = CGSize(width: Globals.screenSize.width * scale, height: Globals.screenSize.height * scale)
        var sizeRect = CGRectMake(0, 0, size.width, size.height)
        
        UIGraphicsBeginImageContext(size)
        view.drawViewHierarchyInRect(sizeRect, afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        var coreImage = CIImage(image: image)
        
        var imageExtent = coreImage.extent()
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        var clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter.setValue(coreImage, forKey: kCIInputImageKey)
        clampFilter.setValue(NSValue(CGAffineTransform: transform), forKey:"inputTransform")

//        let colorFilter = CIFilter(name: "CIColorClamp")
//        colorFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
//        colorFilter.setValue(CIVector(CGRect: CGRectMake(0.7, 0.7, 0.7, 0)), forKey: "inputMinComponents")
//        
//        let secondColorFilter = CIFilter(name: "CIColorControls")
//        secondColorFilter.setValue(colorFilter.outputImage, forKey: kCIInputImageKey)
//        secondColorFilter.setValue(3, forKey: "inputSaturation")
//        secondColorFilter.setValue(0, forKey: "inputBrightness")
//        secondColorFilter.setValue(1, forKey: "inputContrast")
        
        
        let gaussianFilter = CIFilter(name: "CIGaussianBlur")
        gaussianFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        gaussianFilter.setValue(inputRadius, forKey: "inputRadius")
        
        
        let filteredImageData = gaussianFilter.valueForKey(kCIOutputImageKey) as CIImage
        
        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: sizeRect)
        let filteredImage = UIImage(CGImage: filteredImageRef)
        
//        filteredImage.renderingMode 
        backgroundImage.image = filteredImage
//        DefinitionPopover.instance.background.
        UIGraphicsEndImageContext()
    }
    
    func onAddWordsFromList() {
        //println("onAddWordsFromList")
        
        //var predicate: [(EntityProperties, AnyObject)] = [(CardProperties.enabled, false)
//]
        
//        var add: (EntityProperties, AnyObject) =         predicate.append(add)
        
        var cards: [Card] = []
        var color = Globals.colorLists
        var enableOnAdd: Bool = false
        
        switch Globals.notificationTransitionToView.value {
        case .AddWords(let enableOnAddWords):
            enableOnAdd = enableOnAddWords
        default:
            break
        }
        
        switch Globals.notificationAddWordsFromList.value {
        case .AllWords:
            break;
        case .Jlpt4:
            cards = managedObjectContext.fetchCardsJLPT4Suspended()
        case .Jlpt3:
            cards = managedObjectContext.fetchCardsJLPT3Suspended()
        case .Jlpt2:
            cards = managedObjectContext.fetchCardsJLPT2Suspended()
        case .Jlpt1:
            cards = managedObjectContext.fetchCardsJLPT1Suspended()
        case .MyWords:
            cards = managedObjectContext.fetchCardsWillStudy()
            color = Globals.colorMyWords
            enableOnAdd = true
        case .AllWords:
            cards = managedObjectContext.fetchCardsAllWordsSuspended()
        default:
            break;
        }
        
        var addCards: [NSNumber] = []
        
        var added = 0
        
        for card in cards {
            var onlyStudyKanji = settings.onlyStudyKanji.boolValue
            
            if !onlyStudyKanji ||
            (onlyStudyKanji && card.kanji.isPrimarilyKanji()) ||
            Globals.notificationAddWordsFromList.value.description() == WordList.MyWords.description() {
                added++
                addCards.append(card.index)
            }
            
            if added >= settings.cardAddAmount.integerValue {
                break
            }
        }
        
        Globals.notificationTransitionToView.postNotification(.Lists(title: "Words to Add", color: color, cards: addCards, displayAddButton: true, enableOnAdd: enableOnAdd))
    }
}