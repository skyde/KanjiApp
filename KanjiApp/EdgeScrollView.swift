import Foundation
import UIKit
import SpriteKit

public enum EdgeRevealType {
    case Left
    case Right
}

public class EdgeReveal : UIButton {
    
    let revealType: EdgeRevealType
    let maxReveal: CGFloat
    let animationTime = 0.22
    let animationEasing = UIViewAnimationOptions.CurveEaseOut
    let transitionThreshold: CGFloat = 30
    var swipeAreaWidth: CGFloat = 13
    
    var swipeArea: UIButton
    
    var onUpdate: (offset: CGFloat) -> ()
    var onComplete: (isOpen: Bool) -> ()
    
    public init(
        parent: UIView,
        revealType: EdgeRevealType,
        maxOffset: CGFloat = 202,
        autoAddToParent: Bool = true,
        onUpdate: (offset: CGFloat) -> (),
        onComplete: (isOpen: Bool) -> ()) {
        
        self.revealType = revealType
        self.maxReveal = maxOffset
        
        swipeArea = UIButton(frame: CGRectMake(Globals.screenSize.width - swipeAreaWidth, 0, swipeAreaWidth, Globals.screenSize.height))
        swipeArea.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
            
        self.onUpdate = onUpdate
        self.onComplete = onComplete
        
        super.init(frame: CGRectMake(0, 0, 0, 0))
        
        if autoAddToParent {
            parent.addSubview(swipeArea)
            parent.bringSubviewToFront(swipeArea)
        }
        
        var gesture = UIPanGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeArea.addGestureRecognizer(gesture)
        
        var tap = UITapGestureRecognizer(target: self, action: "respondToSwipeTap:")
        swipeArea.addGestureRecognizer(tap)

    }
    
    /// Do not call this method
    public required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    private func updateSidebarFrames(offset: CGFloat) {
        
    }
    
    private func animateSidebar(open: Bool) {
        
        if open {
//        sidebarLeft.hidden = false
//        sidebarRight.hidden = false
        //
        UIView.animateWithDuration(animationTime,
            delay: 0,
            options: animationEasing,
            {
                self.updateSidebarFrames(self.maxReveal)
                
                let viewVisibleWidth = Globals.screenSize.width - self.maxReveal
                
                self.swipeArea.frame = CGRectMake(0, 0,viewVisibleWidth, Globals.screenSize.height)
//                self.outputText.frame.origin.x = viewVisibleWidth - self.outputText.frame.width
//                RootContainer.instance.blurImage.frame.origin.x = viewVisibleWidth - RootContainer.instance.blurImage.frame.width
            },
            nil)
    } else {
        UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
//                    self.updateSidebarFrames(0)
                    
                    self.swipeArea.frame = CGRectMake(Globals.screenSize.width - self.swipeAreaWidth, 0,self.swipeAreaWidth, Globals.screenSize.height)
//                    self.outputText.frame.origin.x = 0
//                    RootContainer.instance.blurImage.frame.origin.x = 0
                },
                completion: { (_) -> Void in
//                        self.sidebarLeft.hidden = true
//                        self.sidebarRight.hidden = true
                })
        }
    }
    
    func respondToSwipeTap(gesture: UITapGestureRecognizer) {
//        if outputText.frame.origin.x != 0 {
        animateSidebar(false)
//        }
        //        println("tap")
    }
    
    func respondToSwipeGesture(gesture: UIPanGestureRecognizer) {
        var xOffset = Globals.screenSize.width - gesture.locationInView(self.superview).x
        xOffset = max(0, xOffset)
        xOffset = min(xOffset, maxReveal)
        
        let x = Globals.screenSize.width - xOffset
        
        swipeArea.frame.origin.x = x - swipeArea.frame.width
//        outputText.frame.origin.x = x - outputText.frame.width
//        RootContainer.instance.blurImage.frame.origin.x = x - RootContainer.instance.blurImage.frame.width
//        
//        sidebarLeft.hidden = xOffset == 0
//        sidebarRight.hidden = xOffset == 0
        
        updateSidebarFrames(xOffset)
        
        switch gesture.state {
        case .Ended:
            var xDelta = -gesture.translationInView(self.superview).x
        if xDelta > transitionThreshold {
            animateSidebar(true)
        } else if xDelta < transitionThreshold {
            animateSidebar(false)
        } else if xDelta < 0 {
            animateSidebar(true)
        } else {
            animateSidebar(false)
            }
        default:
            break
        }
    }

}