import Foundation
import UIKit

class AddRemoveButton: UIButton {
    public func onInteract() {
        
        var baseFrame = frame
        
        let outset: CGFloat = 3
        self.transform = CGAffineTransformMakeScale(outset, outset)
        
        UIView.animateWithDuration(0.3,
            delay: NSTimeInterval(),
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.transform = CGAffineTransformMakeScale(1, 1)
            },
            completion: nil)

    }
    
    public func setButtonType(isAdd: Bool) {
        var path = ""
        
        if isAdd {
            path = "plusIcon.png"
        } else {
            path = "minusIcon.png"
        }
        
        self.setBackgroundImage(UIImage(named: path), forState: UIControlState.Normal)
    }
}