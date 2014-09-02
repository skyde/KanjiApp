import Foundation
import UIKit

public class CardPropertiesSidebar : UIViewController {
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var undoButton: UIButton!
    var currentType: CardPropertiesType = .KnownAndAdd
    
    @IBOutlet weak var undoHeight: NSLayoutConstraint!
    var baseUndoHeight: CGFloat? = nil
    
    var onUndoButtonTap: (() -> ())?
    var onKnownButtonTap: (() -> ())?
    var onAddButtonTap: (() -> ())?
    var onRemoveButtonTap: (() -> ())?
    
    func updateContents(card: Card?, var showUndoButton: Bool) {
        
        if baseUndoHeight == nil {
            baseUndoHeight = undoHeight.constant
        }
        
        if showUndoButton {
            undoHeight.constant = baseUndoHeight!
        } else {
            undoHeight.constant = 0
        }
        undoButton.hidden = !showUndoButton
        
        if let card = card {
            if card.suspended.boolValue {
                setPropertiesType(card, .KnownAndAdd)
            } else if card.known.boolValue {
                setPropertiesType(card, .RemoveAndAdd)
            } else {
                setPropertiesType(card, .RemoveAndKnow)
            }
        }
    }
    @IBAction func undoTap(sender: AnyObject) {
        
        if let onUndoButtonTap = self.onUndoButtonTap {
            onUndoButtonTap()
        }
    }
    
    private func onTap(property: CardPropertiesEdit) {
        
        Globals.notificationEditCardProperties.postNotification(property)

        switch property {
        case .Add:
            if let callback = self.onAddButtonTap {
                callback()
            }
        case .Known:
            if let callback = self.onKnownButtonTap {
                callback()
            }
        case .Remove:
            if let callback = self.onRemoveButtonTap {
                callback()
            }
        }
    }
    
    @IBAction func leftTap(sender: AnyObject) {
        var property: CardPropertiesEdit!
        
        switch currentType {
        case .KnownAndAdd:
            property = .Known
        case .RemoveAndAdd:
            property = .Remove
            break
        case .RemoveAndKnow:
            property = .Remove
            break
        }
        
        onTap(property)
    }
    
    @IBAction func rightTap(sender: AnyObject) {
        var property: CardPropertiesEdit!
        
        switch currentType {
        case .KnownAndAdd:
            property = .Add
        case .RemoveAndAdd:
            property = .Add
            break
        case .RemoveAndKnow:
            property = .Known
            break
        }
        
        onTap(property)
    }
    
    public func animate(offset: CGFloat) {
        leftButton.frame.origin.x = min(0, -leftButton.frame.width + offset)
        rightButton.frame.origin.x = max(0, offset - leftButton.frame.width)
    }
    
//    public override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        self.view.bringSubviewToFront(rightButton)
//    }
//    
//    public override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//    }
    
    func setPropertiesType(card: Card, _ type: CardPropertiesType) {
        
//        leftButton.titleLabel.numberOfLines = 0
//        rightButton.titleLabel.numberOfLines = 0
//        
//        leftButton.titleLabel.textAlignment = .Center
//        rightButton.titleLabel.textAlignment = .Center
        
        currentType = type
        
        var addText = "Add"//"Will\nStudy"
        let knownText = "Known"
        let removeText = "Remove"
        
//        if card.enabled.boolValue {
//            addText = "Study"
//        }
        
        let addColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
        let knownColor = UIColor(
            red: 102.0 / 255.0,
            green: 204.0 / 255.0,
            blue: 255.0 / 255.0,
            alpha: 1)
        let removeColor = UIColor(
            red: 255.0 / 255.0,
            green: 102.0 / 255.0,
            blue: 102.0 / 255.0,
            alpha: 1)
        var leftText = ""
        var rightText = ""
        var leftColor = UIColor()
        var rightColor = UIColor()
        
        switch type {
        case .KnownAndAdd:
            leftText = knownText
            rightText = addText
            
            leftColor = knownColor
            rightColor = addColor
        case .RemoveAndAdd:
            leftText = removeText
            rightText = addText
            
            leftColor = removeColor
            rightColor = addColor
            break
        case .RemoveAndKnow:
            leftText = removeText
            rightText = knownText
            
            leftColor = removeColor
            rightColor = knownColor
            break
        }
        
        leftButton.setTitle(leftText, forState: .Normal)
        rightButton.setTitle(rightText, forState: .Normal)
        
        leftButton.setTitleColor(adjustToForegroundColor(leftColor), forState: .Normal)
        rightButton.setTitleColor(adjustToForegroundColor(rightColor), forState: .Normal)
        
        leftButton.backgroundColor = adjustToBackgroundColor(leftColor)
        rightButton.backgroundColor = adjustToBackgroundColor(rightColor)
    }
    
    func adjustToBackgroundColor(color: UIColor) -> UIColor {
        
        var h: CGFloat = 0, s: CGFloat = 0, b :CGFloat = 0, a :CGFloat = 0
        
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(hue: h, saturation: 0.3, brightness: min(b + 0.4, 1), alpha: a)
    }
    
    func adjustToForegroundColor(color: UIColor) -> UIColor {
        
        var h: CGFloat = 0, s: CGFloat = 0, b :CGFloat = 0, a :CGFloat = 0
        
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(hue: h, saturation: s, brightness: max(b - 0.6, 0), alpha: a)
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