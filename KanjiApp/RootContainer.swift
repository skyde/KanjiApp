import Foundation
import UIKit
import QuartzCore
import CoreData

var rootContainerInstance: RootContainer? = nil

class RootContainer: CustomUIViewController {
    
    class var instance: RootContainer {
        get { return rootContainerInstance! }
    }
//    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var selfBlur: UIVisualEffectView!
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var definitionOverlay: UIView!
    var sidebarEdgeReveal: EdgeReveal!
    var definitionEdgeReveal: EdgeReveal!
    @IBOutlet weak var mainViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var definitionViewLeadingConstraint: NSLayoutConstraint!
    
    var sidebarButtonBaseX: CGFloat = 13
    var statusBarHidden = false
    let popoverAnimationSpeed = 0.17
    let blurEasing = UIViewAnimationOptions.CurveEaseOut
    let sidebarShadowOpacity: Float = 0.5
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootContainerInstance = self
        
        self.sidebar.layer.rasterizationScale = Globals.retinaScale
        self.mainView.layer.rasterizationScale = Globals.retinaScale
        
        selfBlur.hidden = true
        
        sidebarEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Left,
            maxOffset: { return self.sidebar.frame.width },
            autoAddToParent: false,
            onUpdate: {(offset) in
                self.mainView.frame.origin.x = offset
                self.sidebarButton.frame.origin.x = self.sidebarButtonBaseX + offset
                self.sidebar.frame.origin.x = 0.25 * -(self.sidebarEdgeReveal.maxReveal() - offset)
            },
            setVisible: {(visible, completed) in
                self.definitionEdgeReveal?.animateSelf(false)
                
                self.sidebar.visible = visible
                Globals.notificationSidebarInteract.postNotification(visible)
                
                self.setSelfShadow(visible)
                
                if visible {
                    if self.sidebarEdgeReveal.animationState.IsDragging() {
                        self.setNeedsStatusBarAppearanceUpdate()
                    }
                }
//                else {
//                    self.mainView.layer.shouldRasterize = false
//                }
        })
        
        sidebarEdgeReveal.onAnimationStarted = { (isNowOpen) in
            self.sidebar.layer.shouldRasterize = true
            self.mainView.layer.shouldRasterize = true
        }
        
        sidebarEdgeReveal.onAnimationCompleted = { (isNowOpen) in
            self.sidebar.layer.shouldRasterize = false
            if !isNowOpen {
                self.mainView.layer.shouldRasterize = false
            }
            
            if isNowOpen {
                self.mainViewLeadingConstraint.constant = self.sidebarEdgeReveal.maxReveal()
            } else {
                self.mainViewLeadingConstraint.constant = 0
            }
            
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseOut,
                {
                    self.setNeedsStatusBarAppearanceUpdate()
                },
                completion: nil )
        }
        
        view.insertSubview(sidebarEdgeReveal, belowSubview: sidebarButton)
        
        definitionEdgeReveal = EdgeReveal(
            parent: view,
            revealType: .Right,
            maxOffset: { return Globals.screenSize.width },
            swipeAreaWidth: 0,
            maxYTravel: 60,
            onUpdate: {(offset: CGFloat) -> () in
                self.definitionOverlay.frame.origin.x = Globals.screenSize.width - offset
                self.selfBlur.frame.origin.x = Globals.screenSize.width - offset
//                self.selfBlur.alpha = offset / self.definitionEdgeReveal.maxReveal()
            },
            setVisible: {(visible, completed) in
                if visible {
                    if self.definitionConstraintsNeedUpdating {
                        self.layoutDefinitionConstraints()
                    }
//                    self.backgroundImage.image = self.caculateSelfBlurImage()
                    DefinitionPopover.instance.updateState()
                } else {
                    Globals.notificationShowDefinition.value = ""
                }
                
                self.selfBlur.visible = visible
                self.definitionOverlay.visible = visible
        })
        
        definitionEdgeReveal.onAnimationStarted = { (isNowOpen) in
            self.mainView.layer.shouldRasterize = true
        }
        
        definitionEdgeReveal.onAnimationCompleted = { (isNowOpen) in
            if !isNowOpen {
                self.mainView.layer.shouldRasterize = false
            }
        }
        
        definitionEdgeReveal.maxRevealInteractInset = 13
        
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        mainView.layer.shadowOffset = CGSizeMake(-2, 0)
        
        updateDefinitionViewConstraints()
        
//        definitionViewLeadingConstraint
    }
    
    func updateDefinitionViewConstraints() {
        definitionViewLeadingConstraint.constant = Globals.notificationShowDefinition.value == "" ? Globals.screenSize.width : 0
    }
    
    func setSelfShadow(visible: Bool) {
        if visible {
            self.mainView.layer.shadowOpacity = self.sidebarShadowOpacity
            mainView.layer.shadowRadius = 18
        } else {
            self.mainView.layer.shadowOpacity = 0
            mainView.layer.shadowRadius = 0
        }
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
//        self.mainView.layer.shouldRasterize = true
        
        sidebarEdgeReveal.toggleOpenClose()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    override func onTransitionToView() {
        super.onTransitionToView()
        
        if Globals.notificationShowDefinition.value != "" {
            Globals.notificationShowDefinition.postNotification("")
        }
        
        sidebarEdgeReveal.animateSelf(false)
        
        sidebarButton.visible = isGameMode ? !settings.hideSidebarButton.boolValue : true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        definitionOverlay.hidden = true
        sidebar.hidden = true
        selfBlur.hidden = true
    }
    
    func layoutDefinitionConstraints() {
        definitionConstraintsNeedUpdating = false
        DefinitionPopover.instance.view.setNeedsLayout()
    }
    
    var definitionConstraintsNeedUpdating: Bool = false
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateDefinitionViewConstraints()
        view.setNeedsLayout()
        DefinitionPopover.instance.view.setNeedsLayout()
        
        definitionConstraintsNeedUpdating = true
//        DefinitionPopover.instance.definitionLabel.setNeedsUpdateConstraints()
//        DefinitionPopover.instance.definitionLabel.setNeedsLayout()
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onNotificationShowDefinition")
        
        Globals.notificationAddWordsFromList.addObserver(self, selector: "onAddWordsFromList")
        
        Globals.notificationGameViewDidAppear.addObserver(self, selector: "onGameViewDidAppear")
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "", name: <#String!#>, object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: id, object: object)
    }
    
    func onGameViewDidAppear() {
//        println("onGameViewDidAppear")
        
        sidebarEdgeReveal.visible = Globals.notificationGameViewDidAppear.value.sidebarEnabled
    }
//
////        var alert = UIAlertController(title: "Import Lists", message: "Warning, importing lists will delete all current user data, and replace it with the data from the imported file. Are you sure you wish to continue?", preferredStyle: UIAlertControllerStyle.Alert)
////        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
////        alert.addAction(UIAlertAction(title: "Import",
////            style: .Destructive,
////            handler: {alert in println("Import"); RootContainer.instance.navigationController?.popToRootViewControllerAnimated(false)}))
////        alert.modalPresentationStyle = UIModalPresentationStyle.Popover
////        presentViewController(alert, animated: true, completion: nil)
//    }
    
//    func caculateSelfBlurImage() -> UIImage {
//        var scale: CGFloat = 0.125 / 2
//        var inputRadius:CGFloat = 20
//        
//        scale *= Globals.retinaScale
//        inputRadius *= scale
//        let ciContext = CIContext(options: nil)
//        var size = CGSize(width: Globals.screenSize.width * scale, height: Globals.screenSize.height * scale)
//        var sizeRect = CGRectMake(0, 0, size.width, size.height)
//        
//        UIGraphicsBeginImageContext(size)
//        view.drawViewHierarchyInRect(sizeRect, afterScreenUpdates: false)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        var coreImage = CIImage(image: image)
//        
//        var imageExtent = coreImage.extent()
//        
//        var transform: CGAffineTransform = CGAffineTransformIdentity
//        var clampFilter = CIFilter(name: "CIAffineClamp")
//        clampFilter.setValue(coreImage, forKey: kCIInputImageKey)
//        clampFilter.setValue(NSValue(CGAffineTransform: transform), forKey:"inputTransform")
//        
//        //        let colorFilter = CIFilter(name: "CIColorClamp")
//        //        colorFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
//        //        colorFilter.setValue(CIVector(CGRect: CGRectMake(0.7, 0.7, 0.7, 0)), forKey: "inputMinComponents")
//        //
//        //        let secondColorFilter = CIFilter(name: "CIColorControls")
//        //        secondColorFilter.setValue(colorFilter.outputImage, forKey: kCIInputImageKey)
//        //        secondColorFilter.setValue(3, forKey: "inputSaturation")
//        //        secondColorFilter.setValue(0, forKey: "inputBrightness")
//        //        secondColorFilter.setValue(1, forKey: "inputContrast")
//        
//        
//        let gaussianFilter = CIFilter(name: "CIGaussianBlur")
//        gaussianFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
//        gaussianFilter.setValue(inputRadius, forKey: "inputRadius")
//        
//        
//        let filteredImageData = gaussianFilter.valueForKey(kCIOutputImageKey) as CIImage
//        
//        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: sizeRect)
//        let filteredImage = UIImage(CGImage: filteredImageRef)
//        
//        //        backgroundImage.image = filteredImage
//        UIGraphicsEndImageContext()
//        
//        return filteredImage!
//    }
    
//    func caculateSelfImage() -> UIImage {
//        var scale: CGFloat = 1
//        
//        scale *= Globals.retinaScale
//        let ciContext = CIContext(options: nil)
//        var size = CGSize(width: Globals.screenSize.width * scale, height: Globals.screenSize.height * scale)
//        var sizeRect = CGRectMake(0, 0, size.width, size.height)
//        
//        UIGraphicsBeginImageContext(size)
//        view.drawViewHierarchyInRect(sizeRect, afterScreenUpdates: false)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        var coreImage = CIImage(image: image)
//        
//        let filteredImageRef = ciContext.createCGImage(coreImage, fromRect: sizeRect)
//        let filteredImage = UIImage(CGImage: filteredImageRef)
//        
//        //        backgroundImage.image = filteredImage
//        UIGraphicsEndImageContext()
//        
//        return filteredImage
//    }
    
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
        
        var addCards: [NSManagedObject] = []
        
        var added = 0
        
        for card in cards {
            var onlyStudyKanji = settings.onlyStudyKanji.boolValue
            
            if !onlyStudyKanji ||
            (onlyStudyKanji && card.kanji.isPrimarilyKanji()) ||
            Globals.notificationAddWordsFromList.value.description() == WordList.MyWords.description() {
                added++
                addCards.append(card)
            }
            
            if added >= settings.cardAddAmount.integerValue {
                break
            }
        }
        
        Globals.notificationTransitionToView.postNotification(.Lists(
            title: "Words to Add",
            color: color,
            cards: addCards,
            displayConfirmButton: true,
            displayAddButton: false,
            sourceList: Globals.notificationAddWordsFromList.value,
            enableOnAdd: enableOnAdd))
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    private var isGameMode: Bool {
    get {
        return View.GameMode(studyAheadAmount: 0, runTutorial: false).description() == Globals.notificationTransitionToView.value.description()
    }
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
        
        var isSidebarClosed = true
        
        if sidebarEdgeReveal != nil {
            isSidebarClosed = sidebarEdgeReveal.animationState == AnimationState.Closed
        }
        
        var visible = !isGameMode
        
        if isGameMode && !isSidebarClosed {
            visible = true
        }
        
        if !orientationPass {
            visible = false
        }
        
        return !visible
    }
}