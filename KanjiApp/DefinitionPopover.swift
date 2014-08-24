import Foundation
import UIKit
import SpriteKit

var definitionPopoverInstance: DefinitionPopover? = nil

class DefinitionPopover : CustomUIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var outputText: UITextView!
//    @IBOutlet weak var addRemoveButton: AddRemoveButton!
    @IBOutlet weak var addRemoveSidebar: UIView!
    
    var edgeReveal: EdgeReveal! = nil
    var propertiesSidebar: CardPropertiesSidebar {
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
            propertiesSidebar.updateContents(card, showUndoButton: false)
        }
    }
    
    private func updateButtonState(card: Card) {
//        addRemoveButton.setButtonType(card.suspended.boolValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupEdgeReveal()
        setupGestures()
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationEditCardProperties.addObserver(self, selector: "onEditCard", object: nil)
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "onSidebarInteract", object: nil)
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onNotificationShowDefinition")
    }
    
    func onSidebarInteract() {
        edgeReveal.animateSidebar(false)
    }
    
    func onEditCard() {
        if !view.hidden {
            edgeReveal.editCardProperties(viewCard, value: Globals.notificationEditCardProperties.value)
            
            saveContext()
        }
    }
    
    private func setupEdgeReveal() {
        edgeReveal = EdgeReveal(
            parent: view,
            revealType: .Right,
            swipeAreaWidth: 0,
            transitionThreshold: 30,
            handlePan: false,
            maxYTravel: 60,
            onUpdate: {(offset: CGFloat) -> () in
                self.outputText.frame.origin.x = -offset
                self.addRemoveSidebar.frame.origin.x = Globals.screenSize.width - offset
                self.propertiesSidebar.animate(offset)
            },
            setVisible: {(isVisible: Bool) -> () in
                self.addRemoveSidebar.hidden = !isVisible
                if let card = self.viewCard {
                    self.propertiesSidebar.updateContents(card, showUndoButton: false)
                }
        })
    }

//    @IBAction func onAddRemoveButtonTouch(sender: AnyObject) {
//        if let viewCard = viewCard {
//            viewCard.suspended = !viewCard.suspended.boolValue
//            
//            addRemoveButton.onInteract()
//            updateButtonState(viewCard)
//            
//            saveContext()
//        }
//    }
    
    func setupGestures() {
        var tapGesture = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
        self.view.addGestureRecognizer(tapGesture)
        var panGesture = UIPanGestureRecognizer(target: self, action: "respondToPanGesture:")
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func onNotificationShowDefinition() {
        updateText()
    }
    
    func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        edgeReveal.respondToPanGesture(gesture)
//        switch gesture.state {
//        case .Changed:
//            println(gesture.translationInView(self.view))
//        default:
//            break
//        }
    }
    
    func respondToTapGesture(gesture: UIGestureRecognizer) {
        var tapLocation = gesture.locationInView(self.view)
        
        if Globals.notificationShowDefinition.value != "" && CGRectContainsPoint(self.view.layer.presentationLayer().frame, tapLocation) {
            Globals.notificationShowDefinition.postNotification("")
        }
    }
}