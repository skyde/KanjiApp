import Foundation
import UIKit
import SpriteKit

public enum EdgeRevealType {
    case Left
    case Right
}

public class EdgeReveal: UIButton {
    
    let revealType: EdgeRevealType
    let maxReveal: (() -> (CGFloat))
    let animationTime: Double
    let animationEasing = UIViewAnimationOptions.CurveEaseOut
    let transitionThreshold: CGFloat
    let maxYTravel: CGFloat
    var swipeAreaWidth: CGFloat
//    var swipeArea: UIButton!
    var maxRevealInteractInset: CGFloat = 0
    
    var onUpdate: ((offset: CGFloat) -> ())?
    var setVisible: ((open: Bool, completed: Bool) -> ())?
    var onAnimationStarted: ((isNowOpen: Bool) -> ())?
    var onAnimationCompleted: ((isNowOpen: Bool) -> ())?
    var onTap: ((open: Bool) -> ())?
    var onOpenClose: ((shouldOpen: Bool) -> ())?
    
    var animationState: AnimationState = AnimationState.Closed
    
    var allowOpen: Bool = true
    
    public init(
        parent: UIView,
        revealType: EdgeRevealType,
        maxOffset: (() -> (value: CGFloat)) = {() in return 202 },
        autoAddToParent: Bool = true,
        swipeAreaWidth: CGFloat = 13,
        transitionThreshold: CGFloat = 30,
        maxYTravel: CGFloat = CGFloat.max,
        autoHandlePanEvent: Bool = true,
        animationTime: Double = 0.17,
        onUpdate: ((offset: CGFloat) -> ())?,
        setVisible: ((visible: Bool, completed: Bool) -> ())?) {
            
        self.revealType = revealType
        self.maxReveal = maxOffset
        self.maxYTravel = maxYTravel
        self.onUpdate = onUpdate
        self.setVisible = setVisible
        self.swipeAreaWidth = swipeAreaWidth
        self.transitionThreshold = transitionThreshold
        self.animationTime = animationTime
            
//        var t =
            
        super.init(frame: getSwipeAreaFrame(false))
            
//        swipeArea = UIButton(frame: )
        
//        backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
            
        if autoAddToParent {
            parent.addSubview(self)
//            parent.bringSubviewToFront(swipeArea)
        }
        
        if autoHandlePanEvent {
            var gesture = UIPanGestureRecognizer(target: self, action: "respondToPanGesture:")
            addGestureRecognizer(gesture)
        }
        
        var tap = UITapGestureRecognizer(target: self, action: "respondToTap:")
        addGestureRecognizer(tap)
            
        if let setVisible = setVisible {
            setVisible(visible: false, completed: false)
        }
    }
    
    private func getSwipeAreaFrame(isOpen: Bool) -> CGRect {
        switch revealType {
        case .Left:
            if isOpen {
                return CGRectMake(maxReveal() - maxRevealInteractInset, 0, Globals.screenSize.width - maxReveal() + maxRevealInteractInset, Globals.screenSize.height)
            } else { 
                return CGRectMake(0, 0, swipeAreaWidth, Globals.screenSize.height)
            }
        case .Right:
            if isOpen {
                return CGRectMake(0, 0, Globals.screenSize.width - self.maxReveal() + maxRevealInteractInset, Globals.screenSize.height)
            } else {
                return CGRectMake(Globals.screenSize.width - swipeAreaWidth, 0, swipeAreaWidth, Globals.screenSize.height)
            }
        }
    }
    
    public required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    private func setVisibility(value: Bool, completed: Bool) {
        if let setVisible = self.setVisible {
            setVisible(open: value, completed: completed)
        }
    }
    
    public func animateSelf(var open: Bool) {
        if animationState.IsAnimating() {
            return
        }
        if animationState.IsOpenOrClosed() && animationState.AnyOpen() == open {
            return
        }
        
        if let onOpenClose = onOpenClose {
            onOpenClose(shouldOpen: open)
        }
        
        if !allowOpen {
            open = false
        }
        
        let lastAnimationState = animationState
        
        animationState = AnimationState.GetAnimating(open)
        
        if lastAnimationState.IsOpenOrClosed() {
            if let callback = onAnimationStarted {
                callback(isNowOpen: false)
            }
        }
        
        
        let viewVisibleWidth = Globals.screenSize.width - self.maxReveal()
        
        if open {
            if lastAnimationState == AnimationState.Closed {
                setVisibility(true, completed: false)
            }
            
            UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
                    self.frame = self.getSwipeAreaFrame(true)
                    if let onUpdate = self.onUpdate {
                        onUpdate(offset: self.maxReveal())
                    }
                },
                completion: { (_) in
                    self.animationState = .Open
                    if let callback = self.onAnimationCompleted {
                        callback(isNowOpen: true)
                    }
            })
        } else {
            if lastAnimationState == .Open {
                self.frame = self.getSwipeAreaFrame(true)
                if let onUpdate = self.onUpdate {
                    onUpdate(offset: self.maxReveal())
                }
            }
            
            UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
                    self.frame = self.getSwipeAreaFrame(false)
                    if let onUpdate = self.onUpdate {
                        onUpdate(offset: 0)
                    }
                },
                completion: { (_) in
                    self.setVisibility(false, completed: true)
                    self.animationState = .Closed
                    if let callback = self.onAnimationCompleted {
                        callback(isNowOpen: false)
                    }
            })
        }
    }
    
    func respondToTap(gesture: UITapGestureRecognizer) {
        if animationState.IsAnimating() {
            return
        }
        
        if let onTap = self.onTap {
            onTap(open: animationState.AnyOpen())
        }
        
        animateSelf(false)
    }
    
    func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        if animationState.IsAnimating() {
            return
        }
        
        var xSign: CGFloat = 1
        if revealType == .Right {
            xSign = -1
        }
        
        switch gesture.state {
        case .Began:
            if animationState == .Closed {
                animationState = .DraggingOpen
                setVisibility(true, completed: false)
            } else {
                animationState = .DraggingClosed
            }
            
            if let callback = onAnimationStarted {
                callback(isNowOpen: true)
            }
        default:
            break
        }
        
        var xOffset = gesture.translationInView(superview).x * xSign
        
        if !animationState.AnyOpen() {
            xOffset += maxReveal()
        }
        xOffset = max(0, xOffset)
        xOffset = min(xOffset, maxReveal())
        
        if let onUpdate = onUpdate {
            onUpdate(offset: xOffset)
        }
        
        var x = xOffset
        
        if revealType == .Right {
            x = Globals.screenSize.width - x
        
            frame.origin.x = x - frame.width
        } else {
            frame.origin.x = x
        }
        
        switch gesture.state {
        case .Ended:
            let translation = gesture.translationInView(superview)
            var xDelta = translation.x
            
            if revealType == EdgeRevealType.Right {
                xDelta = -xDelta
            }
            
//            if immediatelyClose {
//                
//                
//                
//                animateSelf(false)
//            }
//            else {
            if abs(translation.y) < maxYTravel {
                if xDelta > transitionThreshold {
                    animateSelf(true)
                } else if xDelta < transitionThreshold {
                    animateSelf(false)
                } else {
                    animateSelf(!animationState.AnyOpen())
                }
            }
            else {
                animateSelf(!animationState.AnyOpen())
            }
//            }
        default:
            break
        }
    }
    
    public func toggleOpenClose() {
        if animationState.IsOpenOrClosed() {
            animateSelf(!animationState.AnyOpen())
        }
    }
}