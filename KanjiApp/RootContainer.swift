import Foundation
import UIKit
import QuartzCore

var rootContainerInstance: RootContainer? = nil

class RootContainer: CustomUIViewController {
    
    class var instance: RootContainer {
        get { return rootContainerInstance! }
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var definitionOverlay: UIView!
    var sidebarEdgeReveal: EdgeReveal!
    var definitionEdgeReveal: EdgeReveal!
    
    var sidebarButtonBaseX: CGFloat = 13
    var statusBarHidden = false
    let popoverAnimationSpeed = 0.17
    let blurEasing = UIViewAnimationOptions.CurveEaseOut
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootContainerInstance = self
        
        sidebarEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Left,
            maxOffset: sidebar.frame.width,
            autoAddToParent: false,
            onUpdate: {(offset: CGFloat) -> () in
                self.mainView.frame.origin.x = offset
                self.sidebarButton.frame.origin.x = self.sidebarButtonBaseX + offset
            },
            setVisible: {(visible: Bool, completed: Bool) -> () in
                self.sidebar.visible = visible
                Globals.notificationSidebarInteract.postNotification(visible)
        })
        
        view.insertSubview(sidebarEdgeReveal, belowSubview: sidebarButton)
        
        definitionEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Right,
            maxOffset: Globals.screenSize.width,
            swipeAreaWidth: 0,
            onUpdate: {(offset: CGFloat) -> () in
                self.definitionOverlay.frame.origin.x = Globals.screenSize.width - offset
                self.backgroundImage.alpha = offset / self.definitionEdgeReveal.maxReveal
            },
            setVisible: {(visible: Bool, completed: Bool) -> () in
                if visible {
                    self.backgroundImage.image = self.caculateSelfBlurImage()
                    DefinitionPopover.instance.updateState()
                } else {
                    Globals.notificationShowDefinition.value = ""
                }
                
                self.backgroundImage.visible = visible
                self.definitionOverlay.visible = visible
        })
        definitionEdgeReveal.maxRevealInteractInset = 13
    }
    
    func onNotificationShowDefinition() {
        var animationSpeed: Double = 4
        
        var open = Globals.notificationShowDefinition.value != ""
        
        if !open {
            Globals.notificationShowDefinition.value = "animating"
        }
        
        definitionEdgeReveal.animateSelf(open)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.sendSubviewToBack(mainView)
        self.view.sendSubviewToBack(sidebar)
        
        sidebarButtonBaseX = sidebarButton.frame.origin.x
    }
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        sidebarEdgeReveal.toggleOpenClose()
        
    }
    
//    private func animateSelf(open: Bool) {
////        let xMove: CGFloat =  // 272
////        println()
//        
//        if open {
//            sidebar.hidden = false
//            
//            UIView.animateWithDuration(popoverAnimationSpeed,
//                delay: 0,
//                options: sidebarEasing,
//                {
//                    self.definitionOverlay.frame.origin.x = self.sidebar.frame.width
//                    self.backgroundImage.frame.origin.x = self.sidebar.frame.width
//                    self.mainView.frame.origin.x = self.sidebar.frame.width
//                    self.sidebarButton.frame.origin.x = self.sidebarButtonBaseX + self.sidebar.frame.width
//                    self.swipeFromLeftArea.frame = CGRectMake(
//                        self.sidebar.frame.width,
//                        self.swipeFromLeftArea.frame.origin.y,
//                        Globals.screenSize.width - self.sidebar.frame.width,
//                        self.swipeFromLeftArea.frame.height)
//                },
//                nil)
//        } else {
//            UIView.animateWithDuration(popoverAnimationSpeed,
//            delay: 0,
//            options: sidebarEasing,
//                {
//                    self.definitionOverlay.frame.origin.x = 0
//                    self.backgroundImage.frame.origin.x = 0
//                    self.mainView.frame.origin.x = 0
//                    self.sidebarButton.frame.origin.x = self.sidebarButtonBaseX
//                    self.swipeFromLeftArea.frame = CGRectMake(
//                    0,
//                    self.swipeFromLeftArea.frame.origin.y,
//                    self.swipeFromLeftAreaBaseWidth,
//                    self.swipeFromLeftArea.frame.height)
//                },
//                completion: { (_) -> Void in if self.mainView.layer.presentationLayer().frame.origin.x == 0 { self.sidebar.hidden = true } })
//        }
//    }

    required init(coder aDecoder: NSCoder!) {
        
        super.init(coder: aDecoder)
    }

    override func onTransitionToView() {
        super.onTransitionToView()
        
        if Globals.notificationShowDefinition.value != "" {
            Globals.notificationShowDefinition.postNotification("")
        }
        
        sidebarEdgeReveal.animateSelf(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        definitionOverlay.hidden = true
        sidebar.hidden = true
        backgroundImage.hidden = true
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onNotificationShowDefinition")
        
        Globals.notificationAddWordsFromList.addObserver(self, selector: "onAddWordsFromList")
        
//        Globals.notificationGameViewDidAppear.addObserver(self, selector: "onGameViewDidAppear")
    }
    
//    func onGameViewDidAppear() {
//        println("onGameViewDidAppear")
//        
////        var alert = UIAlertController(title: "Import Lists", message: "Warning, importing lists will delete all current user data, and replace it with the data from the imported file. Are you sure you wish to continue?", preferredStyle: UIAlertControllerStyle.Alert)
////        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
////        alert.addAction(UIAlertAction(title: "Import",
////            style: .Destructive,
////            handler: {alert in println("Import"); RootContainer.instance.navigationController?.popToRootViewControllerAnimated(false)}))
////        alert.modalPresentationStyle = UIModalPresentationStyle.Popover
////        presentViewController(alert, animated: true, completion: nil)
//    }
    
    func caculateSelfBlurImage() -> UIImage {
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
        
//        backgroundImage.image = filteredImage
        UIGraphicsEndImageContext()
        
        return filteredImage
    }
    
    func onAddWordsFromList() {
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
}