import Foundation
import UIKit
import SpriteKit

class DefinitionPopover : CustomUIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet var outputText: UITextView!
    
//    var timer: NSTimer = NSTimer()
    
    var viewCard: Card? {
    get {
        return managedObjectContext.fetchCardByKanji(Globals.currentDefinition)
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText()
        setupGestures()
        
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
        
    }
    
//    func onTimerTick() {
//        caculateBlur()
//    }
    
    func setupGestures() {
        var tapGesture = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func respondToTapGesture(gesture: UIGestureRecognizer) {
        
        var tapLocation = gesture.locationInView(self.view)
        
        if  CGRectContainsPoint(self.view.layer.presentationLayer().frame, tapLocation) {
            Globals.currentDefinition = ""
            NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationShowDefinition, object: nil)
        }
    }
    
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