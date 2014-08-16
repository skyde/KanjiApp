import Foundation
import UIKit

public enum CardPropertiesType {
    case KnownAndAdd
    case RemoveAndAdd
    case RemoveAndKnow
}

public class CardPropertiesSidebar : UIViewController {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    public func animate(offset: CGFloat) {
        leftButton.frame.origin.x = 0
        rightButton.frame.origin.x = max(0, offset - leftButton.frame.width)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.bringSubviewToFront(rightButton)
    }
    
    public func setPropertiesType(type: CardPropertiesType) {
        
    }
    
//    public override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
//        
//        println("test")
//        
//        if (object as NSObject == self && keyPath == "bounds") {
//            // do your stuff, or better schedule to run later using performSelector:withObject:afterDuration:
//        }
//    }
}