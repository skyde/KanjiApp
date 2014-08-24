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
    let animationTime = 0.2
    let animationEasing = UIViewAnimationOptions.CurveEaseOut
    let transitionThreshold: CGFloat
    let maxYTravel: CGFloat
    var swipeAreaWidth: CGFloat
    
    var swipeArea: UIButton
    
    var onUpdate: ((offset: CGFloat) -> ())?
    var setVisible: ((isOpen: Bool) -> ())?
    var onTap: ((isOpen: Bool) -> ())?
    
    var wasOpen = false
    var isOpen: Bool = false
    var animating = false
    
    public init(
        parent: UIView,
        revealType: EdgeRevealType,
        maxOffset: CGFloat = 202,
        autoAddToParent: Bool = true,
        swipeAreaWidth: CGFloat = 13,
        transitionThreshold: CGFloat = 30,
        maxYTravel: CGFloat = CGFloat.max,
        handlePan: Bool = true,
        onUpdate: ((offset: CGFloat) -> ())?,
        setVisible: ((isVisible: Bool) -> ())?) {
            
            self.revealType = revealType
            self.maxReveal = maxOffset
            self.maxYTravel = maxYTravel
            
            swipeArea = UIButton(frame: CGRectMake(Globals.screenSize.width - swipeAreaWidth, 0, swipeAreaWidth, Globals.screenSize.height))
            //        swipeArea.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
            
            self.onUpdate = onUpdate
            self.setVisible = setVisible
            self.swipeAreaWidth = swipeAreaWidth
            self.transitionThreshold = transitionThreshold
            
            super.init(frame: CGRectMake(0, 0, 0, 0))
            
            if autoAddToParent {
                parent.addSubview(swipeArea)
                parent.bringSubviewToFront(swipeArea)
            }
            
            if handlePan {
                var gesture = UIPanGestureRecognizer(target: self, action: "respondToPanGesture:")
                swipeArea.addGestureRecognizer(gesture)
            }
            
            var tap = UITapGestureRecognizer(target: self, action: "respondToTap:")
            swipeArea.addGestureRecognizer(tap)
            
            if let setVisible = setVisible {
                setVisible(isVisible: false)
            }
    }
    
    public required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    //    private func updateSidebarFrames(offset: CGFloat) {
    //
    //    }
    private func onVisibilityChanged(value: Bool) {
        if value != isOpen {
            isOpen = value
            
            if let setVisible = self.setVisible {
                setVisible(isOpen: value)
            }
        }
    }
    
    
    public func animateSidebar(open: Bool) {
        if animating {
            return
        }
        
        animating = true
        
        if open {
            onVisibilityChanged(true)
            
            UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
                    //self.updateSidebarFrames(self.maxReveal)
                    
                    let viewVisibleWidth = Globals.screenSize.width - self.maxReveal
                    
                    self.swipeArea.frame = CGRectMake(0, 0,viewVisibleWidth, Globals.screenSize.height)
                    
                    if let onUpdate = self.onUpdate {
                        onUpdate(offset: self.maxReveal)
                    }
                },
                completion: { (_) -> Void in
                    self.animating = false
            })
        } else {
            UIView.animateWithDuration(animationTime,
                delay: 0,
                options: animationEasing,
                {
                    self.swipeArea.frame = CGRectMake(Globals.screenSize.width - self.swipeAreaWidth, 0, self.swipeAreaWidth, Globals.screenSize.height)
                    if let onUpdate = self.onUpdate {
                        onUpdate(offset: 0)
                    }
                },
                completion: { (_) -> () in
                    self.onVisibilityChanged(false)
                    self.animating = false
            })
        }
    }
    
    func respondToTap(gesture: UITapGestureRecognizer) {
        if animating {
            return
        }
        
        if let onTap = self.onTap {
            onTap(isOpen: isOpen)
        }
        
        animateSidebar(false)
    }
    
    func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        if animating {
            return
        }
        switch gesture.state {
        case .Began:
            wasOpen = isOpen
            onVisibilityChanged(true)
        default:
            break
        }
        
        var xOffset = -gesture.translationInView(self.superview).x//Globals.screenSize.width - gesture.locationInView(self.superview).x
        if wasOpen {
            xOffset += maxReveal
        }
        xOffset = max(0, xOffset)
        xOffset = min(xOffset, maxReveal)
        
        if let onUpdate = onUpdate {
            onUpdate(offset: xOffset)
        }
        
        var x = Globals.screenSize.width - xOffset
        
        swipeArea.frame.origin.x = x - swipeArea.frame.width
        
        //updateSidebarFrames(xOffset)
        
        switch gesture.state {
        case .Ended:
            //            println("ended")maxYDistance
            let t = gesture.translationInView(self.superview)
            let xDelta = -t.x
            if abs(t.y) < maxYTravel {
                if xDelta > transitionThreshold {
                    animateSidebar(true)
                } else if xDelta < transitionThreshold {
                    animateSidebar(false)
                }
                else {
                    animateSidebar(wasOpen)
                }
            }
            else {
                animateSidebar(wasOpen)
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
        
        animateSidebar(false)
    }
}