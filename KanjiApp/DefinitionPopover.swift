import Foundation
import UIKit
import SpriteKit

var definitionPopoverInstance: DefinitionPopover? = nil

class DefinitionPopover : CustomUIViewController {
    
    @IBOutlet var outputText: UITextView!
    @IBOutlet weak var addRemoveButton: AddRemoveButton!
    @IBOutlet weak var addRemoveSidebar: UIView!
    
    var edgeReveal: EdgeReveal! = nil
    var cardPropertiesSidebar: CardPropertiesSidebar {
        return self.childViewControllers[0] as CardPropertiesSidebar
    }
    
    var viewCard: Card? {
    get {
        return managedObjectContext.fetchCardByKanji(Globals.notificationShowDefinition.value)
    }
    }
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    class var instance: DefinitionPopover {
        get { return definitionPopoverInstance! }
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        definitionPopoverInstance = self
    }
    
    func updateText() {
        if let card = viewCard {
            outputText.scrollRangeToVisible(NSRange(location: 0, length: 1))
            outputText.attributedText = card.definitionAttributedText
            outputText.textAlignment = .Center
            outputText.textContainerInset.top = 40
            outputText.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
            
            updateButtonState(card)
            updatePropertySidebar(card)
        }
    }
    
    func updatePropertySidebar(card: Card) {
        if card.suspended.boolValue {
            cardPropertiesSidebar.setPropertiesType(.KnownAndAdd)
        } else if card.known.boolValue {
            cardPropertiesSidebar.setPropertiesType(.RemoveAndAdd)
        } else {
            cardPropertiesSidebar.setPropertiesType(.RemoveAndKnow)
        }
    }
    
    private func updateButtonState(card: Card) {
        addRemoveButton.setButtonType(card.suspended.boolValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupGestures()
        setupAddRemoveSidebar()
        
        Globals.notificationEditCardProperties.addObserver(self, selector: "onEditCard", object: nil)
    }
    
    func onEditCard() {
        if !view.hidden {
            edgeReveal.editCardProperties(viewCard, value: Globals.notificationEditCardProperties.value)
            
            saveContext()
        }
    }
    
    private func setupAddRemoveSidebar() {
        
//        self.view.
//        self.view
        
        edgeReveal = EdgeReveal(
            parent: view,
            revealType: .Right,
            onUpdate: {(offset: CGFloat) -> () in
                self.outputText.frame.origin.x = -offset
                self.addRemoveSidebar.frame.origin.x = Globals.screenSize.width - offset
                self.cardPropertiesSidebar.animate(offset)
            },
            setVisible: {(isVisible: Bool) -> () in
                self.addRemoveSidebar.hidden = !isVisible
                if let card = self.viewCard {
                    self.updatePropertySidebar(card)
                }
        })
//        edgeReveal.ani
        //        sidebarLeft = UIButton(frame: CGRectMake(Globals.screenSize.width, 0, 0, Globals.screenSize.height))
//        view.addSubview(sidebarLeft)
//        
//        sidebarRight = UIButton(frame: CGRectMake(Globals.screenSize.width, 0, 0, Globals.screenSize.height))
//        view.addSubview(sidebarRight)
        
//        updateSidebarText([], [])
        
//        var gesture = UIPanGestureRecognizer(target: self, action: "respondToEdgeSwipeGesture:")
//        swipeFromRightArea.addGestureRecognizer(gesture)
//        
//        var tap = UITapGestureRecognizer(target: self, action: "respondToEdgeSwipeTap:")
//        swipeFromRightArea.addGestureRecognizer(tap)
    }
    
//    private func updateSidebarText(texts: [String], _ colors: [UIColor]) {
//        sidebarLeft.backgroundColor = UIColor.blueColor()
//        sidebarRight.backgroundColor = UIColor.greenColor()
//    }
//    private func updateSidebarFrames(offset: CGFloat) {
//        //let xOffset = -xPosition
//        
////        println(openAmount)
//        
//        sidebarLeft.frame = CGRectMake(Globals.screenSize.width - offset, 0, offset / 2, Globals.screenSize.height)
//        sidebarRight.frame = CGRectMake(Globals.screenSize.width - offset / 2, 0, offset / 2, Globals.screenSize.height)
//    }
    
//    private func animateRightSidebar(open: Bool) {
//        
//        if open {
//            sidebarLeft.hidden = false
//            sidebarRight.hidden = false
////            
//            UIView.animateWithDuration(popoverAnimationSpeed,
//                delay: 0,
//                options: sidebarEasing,
//                {
//                    self.updateSidebarFrames(self.sidebarMaxOffset)
//                    
//                    let viewVisibleWidth = Globals.screenSize.width - self.sidebarMaxOffset
//                    
//                    self.swipeFromRightArea.frame = CGRectMake(0, 0,viewVisibleWidth, Globals.screenSize.height)
//                    self.outputText.frame.origin.x = viewVisibleWidth - self.outputText.frame.width
//                    RootContainer.instance.blurImage.frame.origin.x = viewVisibleWidth - RootContainer.instance.blurImage.frame.width
//                },
//                nil)
//        } else {
//            UIView.animateWithDuration(popoverAnimationSpeed,
//                delay: 0,
//                options: sidebarEasing,
//                {
//                    self.updateSidebarFrames(0)
//                    
//                    self.swipeFromRightArea.frame = CGRectMake(Globals.screenSize.width - self.swipeFromRightAreaBaseWidth, 0,self.swipeFromRightAreaBaseWidth, Globals.screenSize.height)
//                    self.outputText.frame.origin.x = 0
//                    RootContainer.instance.blurImage.frame.origin.x = 0
//                },
//                completion: { (_) -> Void in
//                    self.sidebarLeft.hidden = true
//                    self.sidebarRight.hidden = true
//            })
//        }
//    }
//    
//    func respondToEdgeSwipeTap(gesture: UITapGestureRecognizer) {
//        if outputText.frame.origin.x != 0 {
//            animateRightSidebar(false)
//        }
////        println("tap")
//    }
//    
//    func respondToEdgeSwipeGesture(gesture: UIPanGestureRecognizer) {
//        var xOffset = Globals.screenSize.width - gesture.locationInView(self.view).x
//        xOffset = max(0, xOffset)
//        xOffset = min(xOffset, sidebarMaxOffset)
//        
//        let x = Globals.screenSize.width - xOffset
//        
//        swipeFromRightArea.frame.origin.x = x - swipeFromRightArea.frame.width
//        outputText.frame.origin.x = x - outputText.frame.width
//        RootContainer.instance.blurImage.frame.origin.x = x - RootContainer.instance.blurImage.frame.width
//        
//        sidebarLeft.hidden = xOffset == 0
//        sidebarRight.hidden = xOffset == 0
//        
//        updateSidebarFrames(xOffset)
//        
//        switch gesture.state {
//        case .Ended:
//            var xDelta = -gesture.translationInView(self.view).x
//            if xDelta > sidebarTransitionThreshold {
//                animateRightSidebar(true)
//            } else if xDelta < sidebarTransitionThreshold {
//                animateRightSidebar(false)
//            } else if xDelta < 0 {
//                animateRightSidebar(true)
//            } else {
//                animateRightSidebar(false)
//            }
//        default:
//            break
//        }
//    }
    

    @IBAction func onAddRemoveButtonTouch(sender: AnyObject) {
        
        if let viewCard = viewCard {
            viewCard.suspended = !viewCard.suspended.boolValue
            
            addRemoveButton.onInteract()
            updateButtonState(viewCard)
            
            saveContext()
        }
    }
    
    func setupGestures() {
        var tapGesture = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func respondToTapGesture(gesture: UIGestureRecognizer) {
        var tapLocation = gesture.locationInView(self.view)
        
//        println("respondToTapGesture")
        if Globals.notificationShowDefinition.value != "" && CGRectContainsPoint(self.view.layer.presentationLayer().frame, tapLocation) {
//            println("close")
//            definition = ""
            Globals.notificationShowDefinition.postNotification("")
//            NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationShowDefinition, object: nil)
        }
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        [view drawViewHierarchyInRect:(CGRect){CGPointZero, w, h} afterScreenUpdates:YES]; // view is the view you are grabbing the screen shot of. The view that is to be blurred.
//        var image = UIGraphicsGetImageFromCurrentImageContext();
        
//        edgeReveal.onUpdate!(offset: 0)
//        addRemoveSidebar.frame.origin.x = Globals.screenSize.width
    }
    
    
    func onNotificationShowDefinition() {
//        if definition != "" {
//            definition = Globals.notificationShowDefinition.value
        
//        var animationSpeed = 0.4
        
        updateText()
//        }
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onNotificationShowDefinition")
    }
}