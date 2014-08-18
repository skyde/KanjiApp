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
    
    func updateContents(card: Card?, var showUndoButton: Bool, var onUndoButtonTap: (() -> ())? = nil) {
        
        self.onUndoButtonTap = onUndoButtonTap
        
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
                setPropertiesType(.KnownAndAdd)
            } else if card.known.boolValue {
                setPropertiesType(.RemoveAndAdd)
            } else {
                setPropertiesType(.RemoveAndKnow)
            }
        }
    }
    @IBAction func undoTap(sender: AnyObject) {
        
        if let onUndoButtonTap = self.onUndoButtonTap {
            onUndoButtonTap()
        }
    }
    
    @IBAction func leftTap(sender: AnyObject) {
        switch currentType {
        case .KnownAndAdd:
            Globals.notificationEditCardProperties.postNotification(.Known)
        case .RemoveAndAdd:
            Globals.notificationEditCardProperties.postNotification(.Remove)
            break
        case .RemoveAndKnow:
            Globals.notificationEditCardProperties.postNotification(.Remove)
            break
        }
    }
    
//    public override func awakeFromNib() {
//        super.awakeFromNib()
//        
//    }
    
    @IBAction func rightTap(sender: AnyObject) {
        switch currentType {
        case .KnownAndAdd:
            Globals.notificationEditCardProperties.postNotification(.Add)
        case .RemoveAndAdd:
            Globals.notificationEditCardProperties.postNotification(.Add)
            break
        case .RemoveAndKnow:
            Globals.notificationEditCardProperties.postNotification(.Known)
            break
        }
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
    
    public func setPropertiesType(type: CardPropertiesType) {
        
        currentType = type
        
        let addText = "Add"
        let knownText = "Known"
        let removeText = "Remove"
        
        let addColor = Globals.colorMyWords
        let knownColor = Globals.colorKnown
        let removeColor = Globals.colorLists
        
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