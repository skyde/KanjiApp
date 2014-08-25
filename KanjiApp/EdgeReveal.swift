import Foundation
import UIKit
import SpriteKit

public enum EdgeRevealType {
    case Left
    case Right
}

public enum AnimationState {
    case Closed
    case Opening
    case Open
    case Closing
    case DraggingOpen
    case DraggingClosed
    
    public func IsOpenOrClosed() -> Bool {
        switch self {
        case Open:
            return true
        case Closed:
            return true
        default:
            return false
        }
    }
    
    public func IsAnimating() -> Bool {
        switch self {
        case Opening:
            return true
        case Closing:
            return true
        default:
            return false
        }
    }
    
    public func IsDragging() -> Bool {
        switch self {
        case DraggingOpen:
            return true
        case DraggingClosed:
            return true
        default:
            return false
        }
    }
    
    public func AnyOpen() -> Bool {
        switch self {
        case Open:
            return true
        case Opening:
            return true
        case DraggingOpen:
            return true
        default:
            return false
        }
    }
    
    public static func GetFinished(isOpen: Bool) -> AnimationState {
        if isOpen {
            return AnimationState.Open
        } else {
            return AnimationState.Closed
        }
    }
    
    public static func GetAnimating(isOpen: Bool) -> AnimationState {
        if isOpen {
            return AnimationState.Opening
        } else {
            return AnimationState.Closing
        }
    }
    
    public static func GetDrag(isDraggingOpen: Bool) -> AnimationState {
        if isDraggingOpen {
            return AnimationState.DraggingOpen
        } else {
            return AnimationState.DraggingClosed
        }
    }
    
//    public mutating func SetFinished(isOpen: Bool) {
//        if isOpen {
//            self = AnimationState.Open
//        } else {
//            self = AnimationState.Closed
//        }
//    }
//    
//    public mutating func SetAnimating(isOpen: Bool) {
//        if isOpen {
//            self = AnimationState.Opening
//        } else {
//            self = AnimationState.Closing
//        }
//    }
}

public class EdgeReveal : UIButton {
    
    let revealType: EdgeRevealType
    let maxReveal: CGFloat
    let animationTime = 0.2
    let animationEasing = UIViewAnimationOptions.CurveEaseOut
    let transitionThreshold: CGFloat
    let maxYTravel: CGFloat
    var swipeAreaWidth: CGFloat
    
    var swipeArea: UIButton
    
    var onUpdate: ((offset: CGFloat) -> ())?
    var setVisible: ((isOpen: Bool) -> ())?
    var onTap: ((isOpen: Bool) -> ())?
    
    var animationState: AnimationState = AnimationState.Closed
//    var wasOpen = false
//    var isOpen: Bool = false
//    var animating = false
    
    public init(
        parent: UIView,
        revealType: EdgeRevealType,
        maxOffset: CGFloat = 202,
        autoAddToParent: Bool = true,
        swipeAreaWidth: CGFloat = 13,
        transitionThreshold: CGFloat = 30,
        maxYTravel: CGFloat = CGFloat.max,
        autoHandlePanEvent: Bool = true,
        onUpdate: ((offset: CGFloat) -> ())?,
        setVisible: ((isVisible: Bool) -> ())?) {
            
        self.revealType = revealType
        self.maxReveal = maxOffset
        self.maxYTravel = maxYTravel
        
        swipeArea = UIButton(frame: CGRectMake(Globals.screenSize.width - swipeAreaWidth, 0, swipeAreaWidth, Globals.screenSize.height))
        
        self.onUpdate = onUpdate
        self.setVisible = setVisible
        self.swipeAreaWidth = swipeAreaWidth
        self.transitionThreshold = transitionThreshold
        
        super.init(frame: CGRectMake(0, 0, 0, 0))
        
        if autoAddToParent {
            parent.addSubview(swipeArea)
            parent.bringSubviewToFront(swipeArea)
        }
        
        if autoHandlePanEvent {
            var gesture = UIPanGestureRecognizer(target: self, action: "respondToPanGesture:")
            swipeArea.addGestureRecognizer(gesture)
        }
        
        var tap = UITapGestureRecognizer(target: self, action: "respondToTap:")
        swipeArea.addGestureRecognizer(tap)
            
        if let setVisible = setVisible {
            setVisible(isVisible: false)
        }
    }
    
    private func getSwipeAreaFrame(isOpen: Bool) -> CGRect {
        switch revealType {
        case .Left:
            if isOpen {
                return CGRectMake(maxReveal, 0, Globals.screenSize.width - maxReveal, Globals.screenSize.height)
            } else { 
                return CGRectMake(0, 0, swipeAreaWidth, Globals.screenSize.height)
            }
        case .Right:
            if isOpen {
                return CGRectMake(0, 0, Globals.screenSize.width - self.maxReveal, Globals.screenSize.height)
            } else {
                return CGRectMake(Globals.screenSize.width - swipeAreaWidth, 0, swipeAreaWidth, Globals.screenSize.height)
            }
        }
    }
    
    public required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    //    private func updateSidebarFrames(offset: CGFloat) {
    //
    //    }
    private func setVisibility(value: Bool) {
//        if AnimationState.GetFinished(value) != animationState {
//            animationState = AnimationState.GetFinished(value)
        
        if let setVisible = self.setVisible {
            setVisible(isOpen: value)
        }
//        }
    }
    
    
    public func animateSelf(isOpen: Bool) {
        if animationState.IsAnimating() {
            return
        }
        
        if animationState.IsOpenOrClosed() && animationState.AnyOpen() == isOpen {
            return
        }
//        println("animate self \(isOpen)")
        
        animationState = AnimationState.GetAnimating(isOpen)
        
        if isOpen {
            setVisibility(true)
            
            if animationState == .Closed {
                
                if let onUpdate = self.onUpdate {
                    println("update")
                    onUpdate(offset: 0)
                }
            }
            
            UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
                    //self.updateSidebarFrames(self.maxReveal)
                    
                    let viewVisibleWidth = Globals.screenSize.width - self.maxReveal
                    
                    self.swipeArea.frame = self.getSwipeAreaFrame(true)
                    
                    if let onUpdate = self.onUpdate {
                        onUpdate(offset: self.maxReveal)
                    }
                },
                completion: { (_) -> Void in
                    self.animationState = .Open
                    //self.animating = false
            })
        } else {
            UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
                    self.swipeArea.frame = self.getSwipeAreaFrame(false)
                    if let onUpdate = self.onUpdate {
                        onUpdate(offset: 0)
                    }
                },
                completion: { (_) -> () in
                    self.setVisibility(false)
                    self.animationState = .Closed
            })
        }
    }
    
    func respondToTap(gesture: UITapGestureRecognizer) {
        if animationState.IsAnimating() {
            return
        }
        
        if let onTap = self.onTap {
            onTap(isOpen: animationState.AnyOpen())
        }
        
        animateSelf(false)
    }
    
    func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        if animationState.IsAnimating() {
            return
        }
        
        switch gesture.state {
        case .Began:
            if animationState == .Closed {
                setVisibility(true)
                animationState = .DraggingOpen
            } else {
                animationState = .DraggingClosed
            }
//            animationState = AnimationState.GetAnimating(!animationState.IsAnyOpen())
//            println(animationState)
        default:
            break
        }
        
        var xOffset = -gesture.translationInView(self.superview).x//Globals.screenSize.width - gesture.locationInView(self.superview).x
        if !animationState.AnyOpen() {
            xOffset += maxReveal
        }
        xOffset = max(0, xOffset)
        xOffset = min(xOffset, maxReveal)
        
        if let onUpdate = onUpdate {
            onUpdate(offset: xOffset)
        }
        
        var x = xOffset
        
        if revealType == .Right {
            x = Globals.screenSize.width - x
        }
        
        swipeArea.frame.origin.x = x - swipeArea.frame.width
        
        switch gesture.state {
        case .Ended:
            let translation = gesture.translationInView(self.superview)
            var xDelta = translation.x
            
            if revealType == EdgeRevealType.Right {
                xDelta = -xDelta
            }
            
            if abs(translation.y) < maxYTravel {
                if xDelta > transitionThreshold {
                    animateSelf(true)
                } else if xDelta < transitionThreshold {
                    animateSelf(false)
                }
                else {
                    animateSelf(!animationState.AnyOpen())
                }
            }
            else {
                animateSelf(!animationState.AnyOpen())
            }
        default:
            break
        }
    }
    
    /// Note that this method does not save the context
    func editCardProperties(card: Card?, value: CardPropertiesEdit) {
        if let card = card {
            switch value {
            case .Add:
                card.suspended = false
                card.known = false
            case .Remove:
                card.suspended = true
            case .Known:
                card.suspended = false
                card.known = true
            }
        }
        
        animateSelf(false)
    }
}