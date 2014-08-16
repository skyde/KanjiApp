import Foundation
import UIKit
import SpriteKit

//var definitionPopoverInstance: DefinitionPopover? = nil

class DefinitionPopover : CustomUIViewController {
    
    var swipeFromRightArea: UIButton! = nil
    var swipeFromRightAreaBaseWidth: CGFloat = 13
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet var outputText: UITextView!
    @IBOutlet weak var addRemoveButton: AddRemoveButton!
    
//    public var definition: String = ""
    
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
    
//    class var instance: DefinitionPopover {
//        get { return definitionPopoverInstance! }
//    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
//        println("def init")
//        definitionPopoverInstance = self
    }
    
    func updateText() {
        if let card = viewCard {
            outputText.attributedText = card.definitionAttributedText
            outputText.textAlignment = .Center
            outputText.textContainerInset.top = 40
            outputText.scrollRangeToVisible(NSRange(location: 0, length: 1))
            
            updateButtonState(card)
        }
    }
    
    private func updateButtonState(card: Card) {
        addRemoveButton.setButtonType(card.suspended.boolValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupGestures()
        createSwipeArea()
    }
    
    func createSwipeArea() {
        swipeFromRightArea = UIButton(frame: CGRectMake(Globals.screenSize.width - swipeFromRightAreaBaseWidth, 0, swipeFromRightAreaBaseWidth, Globals.screenSize.height))
        swipeFromRightArea.backgroundColor = UIColor.redColor()
        view.addSubview(swipeFromRightArea)
        
        view.bringSubviewToFront(swipeFromRightArea)
    }
    
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