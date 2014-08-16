import Foundation
import UIKit

public enum CardPropertiesEdit {
    case Add
    case Known
    case Remove
}

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
        
        setPropertiesType(.KnownAndAdd)
    }
    
    public func setPropertiesType(type: CardPropertiesType) {
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
            break
        case .RemoveAndKnow:
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
        
        return UIColor(hue: h, saturation: 0.08, brightness: min(b + 0.4, 1), alpha: a)
    }
    
    func adjustToForegroundColor(color: UIColor) -> UIColor {
        
        var h: CGFloat = 0, s: CGFloat = 0, b :CGFloat = 0, a :CGFloat = 0
        
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(hue: h, saturation: s, brightness: max(b - 0.4, 0), alpha: a)
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