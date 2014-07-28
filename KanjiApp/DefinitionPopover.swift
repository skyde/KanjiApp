import Foundation
import UIKit

class DefinitionPopover : CustomUIViewController {
    @IBOutlet var outputText: UITextView!
    
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
    }
    
    func setupGestures() {
        var tapGesture = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func respondToTapGesture(gesture: UIGestureRecognizer) {        Globals.currentDefinition = ""
        NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationShowDefinition, object: nil)
    }
}