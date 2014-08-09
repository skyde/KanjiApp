import Foundation
import UIKit
import SpriteKit

class DefinitionPopover : CustomUIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet var outputText: UITextView!
    @IBOutlet weak var addRemoveButton: AddRemoveButton!
    
    var viewCard: Card? {
    get {
        return managedObjectContext.fetchCardByKanji(Globals.currentDefinition)
    }
    }
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    func updateText() {
        if let card = viewCard {
            outputText.attributedText = card.definitionAttributedText
            outputText.textAlignment = .Center
            outputText.textContainerInset.top = 40
            outputText.scrollRangeToVisible(NSRange(location: 0, length: 1))
            
            addRemoveButton.setButtonType(!card.enabled.boolValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupGestures()
    }
    
    @IBAction func onAddRemoveButtonTouch(sender: AnyObject) {
        
        if let viewCard = viewCard {
            viewCard.enabled = !viewCard.enabled.boolValue
            
            addRemoveButton.onInteract()
            addRemoveButton.setButtonType(!viewCard.enabled.boolValue)
            
            saveContext()
        }
    }
    
    func setupGestures() {
        var tapGesture = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func respondToTapGesture(gesture: UIGestureRecognizer) {
        var tapLocation = gesture.locationInView(self.view)
        
        if Globals.currentDefinition != "" && CGRectContainsPoint(self.view.layer.presentationLayer().frame, tapLocation) {
            Globals.currentDefinition = ""
            NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationShowDefinition, object: nil)
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
        
        var animationSpeed = 0.4
        
        updateText()
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotificationShowDefinition", name: Globals.notificationShowDefinition, object: nil)
    }
}