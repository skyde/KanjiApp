import Foundation
import UIKit

class AddRemoveButton: UIButton {
    public func onInteract() {
        
//        var duration = 0.5
//        var outset = 10
//        
//        var baseFrame = frame
//        
//        println(self.frame)
        
//        self.con
        
//        self.frame = CGRectMake(
//            self.frame.origin.x - outset,
//            self.frame.origin.y - outset,
//            self.frame.width + outset * 2,
//            self.frame.height + outset * 2)
        
//        println(self.frame)
//        UIView.animateWithDuration(4,
//            delay: NSTimeInterval(),
//            options: UIViewAnimationOptions.CurveEaseOut,
//            animations: {
//                self.frame = baseFrame
//            },
//            completion: {
//                (_) -> Void in println("done")
//            })

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