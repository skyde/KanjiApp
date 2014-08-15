import Foundation
import UIKit
import QuartzCore

var rootContainerInstance: RootContainer? = nil

class RootContainer: CustomUIViewController {
    
    class var instance: RootContainer {
        get { return rootContainerInstance! }
    }
    @IBOutlet weak var swipeFromLeftArea: UIButton!
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var definitionOverlay: UIView!
    @IBOutlet weak var blurImage: UIImageView!
    
    var sidebarButtonBaseX: CGFloat = 0
    var statusBarHidden = false
    let popoverAnimationSpeed = 0.22
    let sidebarEasing = UIViewAnimationOptions.CurveEaseOut
    let blurEasing = UIViewAnimationOptions.CurveEaseOut
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        var open = mainView.frame.origin.x == 0
        
        if Globals.notificationShowDefinition.value != "" {
            Globals.notificationShowDefinition.postNotification("")
        }
        
        Globals.notificationSidebarInteract.postNotification(open)
        
        animateSelf(open)
    }
    
    private func animateSelf(open: Bool) {
        let xMove: CGFloat = 272
        
        if open {
            sidebar.hidden = false
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: sidebarEasing,
                animations: {
                    self.mainView.frame = CGRectMake(xMove, self.mainView.frame.origin.y, self.mainView.frame.width, self.mainView.frame.height)
                },
                completion: nil)
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: sidebarEasing,
                animations: {
                    self.sidebarButton.frame = CGRectMake(
                        self.sidebarButtonBaseX + xMove,
                        self.sidebarButton.frame.origin.y,
                        self.sidebarButton.frame.width,
                        self.sidebarButton.frame.height);
                },
                completion: nil)
        } else {
            UIView.animateWithDuration(popoverAnimationSpeed,
            delay: NSTimeInterval(),
            options: sidebarEasing,
            animations: {
                self.mainView.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height) },
                completion: { (_) -> Void in if self.mainView.layer.presentationLayer().frame.origin.x == 0 { self.sidebar.hidden = true } })
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: sidebarEasing,
                animations: {
                    self.sidebarButton.frame = CGRectMake(
                        self.sidebarButtonBaseX,
                        self.sidebarButton.frame.origin.y,
                        self.sidebarButton.frame.width,
                        self.sidebarButton.frame.height);//self.sidebarButtonBaseFrame
                },
                completion: nil)
            
//            UIView.animateWithDuration(popoverAnimationSpeed) {
//                
//            }
        }
    }

    required init(coder aDecoder: NSCoder!) {
        
        super.init(coder: aDecoder)
    }

    override func onTransitionToView() {
        super.onTransitionToView()
        
        animateSelf(false)
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootContainerInstance = self
        
        Globals.notificationAddWordsFromList.addObserver(self, selector: "onAddWordsFromList")
        
        println("add")
        
        var gesture = UIPanGestureRecognizer(target: self, action: "respondToFromLeftSwipeGesture:")
//        gesture. = .Left
//        gesture.cancelsTouchesInView = false
//        gesture.delaysTouchesBegan = false
//        gesture.delaysTouchesEnded = false
        swipeFromLeftArea.addGestureRecognizer(gesture)
    }
    
    func respondToFromLeftSwipeGesture(gesture: UIPanGestureRecognizer) {
        var x = gesture.locationInView(self.view).x
        x = max(0, x)
        x = min(x, sidebar.frame.width)
        
//        print(sidebar.frame.width)
        
        sidebar.hidden = x == 0
        
        mainView.frame.origin.x = x
        sidebarButton.frame.origin.x = sidebarButtonBaseX + x
        swipeFromLeftArea.frame.origin.x = x
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
        
        return View.GameMode.description() == Globals.notificationTransitionToView.value.description() ||
            !orientationPass
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        definitionOverlay.hidden = true
        sidebar.hidden = true
        blurImage.hidden = true
        blurImage.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.sendSubviewToBack(mainView)
        self.view.sendSubviewToBack(sidebar)
        
        sidebarButtonBaseX = sidebarButton.frame.origin.x
    }
    
    func onNotificationShowDefinition() {
//        var definition = .getObject(notification)
//        println(container)
//        var definition =
        
        var animationSpeed = 0.4
        
        if Globals.notificationShowDefinition.value == "" {
            Globals.notificationShowDefinition.value = "animating"
            self.mainView.hidden = false
            self.blurImage.opaque = false
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: blurEasing,
                animations: {
                    self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height);
                    self.blurImage.alpha = 0
                },
                completion: {
                (_) -> Void in
                    self.definitionOverlay.hidden = true;
                    self.blurImage.hidden = true;
                    Globals.notificationShowDefinition.value = ""
                })
        } else {
            caculateBlur()
            definitionOverlay.hidden = false
            blurImage.hidden = false
            
            self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height)
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: blurEasing,
                animations: {
                    self.definitionOverlay.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height);
                    self.blurImage.alpha = 1
                },
                completion: {
                    (_) -> Void in
                        self.mainView.hidden = true
                        self.blurImage.opaque = true
                })
        }
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onNotificationShowDefinition")
        
//        NSNotificationCenter.defaultCenter().ad
    }
    
    func caculateBlur() {
        let scale: CGFloat = 0.1
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
        
        let gaussianFilter = CIFilter(name: "CIGaussianBlur")
        gaussianFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        gaussianFilter.setValue(inputRadius, forKey: "inputRadius")
        
        let filteredImageData = gaussianFilter.valueForKey(kCIOutputImageKey) as CIImage
        
        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: sizeRect)
        let filteredImage = UIImage(CGImage: filteredImageRef)
        
        blurImage.image = filteredImage
        UIGraphicsEndImageContext()
    }
    
    func onAddWordsFromList() {
        
        //var predicate: [(EntityProperties, AnyObject)] = [(CardProperties.enabled, false)
//]
        
//        var add: (EntityProperties, AnyObject) =         predicate.append(add)
        
        var cards: [Card] = []
        
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
        case .AllWords:
            cards = managedObjectContext.fetchCardsAllWordsSuspended()
        default:
            break;
        }
        
        var addCards: [NSNumber] = []
        
        var added = 0
        
        for card in cards {
//            if let card = card as? Card {
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
//            }
        }
        
        Globals.notificationTransitionToView.postNotification(.Lists(title: "Words to Add", cards: addCards, displayAddButton: true))
    }
}