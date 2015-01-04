import Foundation
import UIKit

public class CardPropertiesSidebar : UIViewController, UIActionSheetDelegate {
    
    @IBOutlet weak var leftButton: UIButton!
//    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var undoButton: UIButton!
    var currentType: CardPropertiesType = .Suspended
    
    @IBOutlet weak var undoHeight: NSLayoutConstraint!
    var baseUndoHeight: CGFloat? = nil
    
    var onUndoButtonTap: (() -> ())?
    //    var onKnownButtonTap: (() -> ())?
    var onPropertyButtonTap: (() -> ())?
    var onCloseSidebar: (() -> ())?
    var currentCard: Card?
    
    @IBAction func onOptionsPress(sender: AnyObject) {
        println("options")
        
        var hiraganaText = ""
        
        if let card = currentCard
        {
            hiraganaText = card.isKanji.boolValue ? "Display as Hiragana" : "Display as Kanji"
        }
        
        var sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: hiraganaText)
        
        sheet.showInView(view)
    }
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1 {
            if let card = currentCard {
                card.isKanji = !card.isKanji.boolValue
            }
        }
        
        if let callback = onCloseSidebar {
            callback()
        }
    }
    /// Note that this method does not save the context
    class func editCardProperties(card: Card, _ value: CardPropertiesType) {
        switch value {
        case .Suspended:
            card.suspended = true
            card.enabled = false
        case .Pending:
            card.suspended = false
            card.enabled = false
            card.known = true
        case .Studying:
            card.suspended = false
            card.enabled = true
            card.known = true
        }
    }
    
    class func cycleCardState(card: Card) {
        if card.suspended.boolValue {
            // Suspended
            editCardProperties(card, .Pending)
        } else if !card.enabled.boolValue {
            // Pending
            editCardProperties(card, .Studying)
        
        } else {
            // Studying
            editCardProperties(card, .Suspended)
        }
    }
    
    func updateContents(card: Card?, var showUndoButton: Bool) {
        
        currentCard = card
        
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
                // Suspended
                setPropertiesType(card, .Pending)
            } else if !card.enabled.boolValue {
                // Pending
                setPropertiesType(card, .Studying)
            } else {
                // Studying
                setPropertiesType(card, .Suspended)
            }
        }
    }
    @IBAction func undoTap(sender: AnyObject) {
        
        if let onUndoButtonTap = self.onUndoButtonTap {
            onUndoButtonTap()
        }
    }
    
    private func onTap() {
        Globals.notificationEditCardProperties.postNotification(currentType)
        
        if let callback = self.onPropertyButtonTap {
            callback()
        }
    }
    
    @IBAction func leftTap(sender: AnyObject) {
//        var property: CardPropertiesEdit!
//        
//        switch currentType {
//        case .Suspended:
//            property = .Known
//        case .Pending:
//            property = .Remove
//            break
//        case .RemoveAndKnow:
//            property = .Remove
//            break
//        }
        
        onTap()
    }
    
//    @IBAction func rightTap(sender: AnyObject) {
//        var property: CardPropertiesEdit!
//        
//        switch currentType {
//        case .KnownAndAdd:
//            property = .Add
//        case .RemoveAndAdd:
//            property = .Add
//            break
//        case .RemoveAndKnow:
//            property = .Known
//            break
//        }
//        
//        onTap(property)
//    }
    
    public func animate(offset: CGFloat) {
//        leftButton.frame.origin.x = min(0, -leftButton.frame.width + offset)
//        rightButton.frame.origin.x = max(0, offset - leftButton.frame.width)
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
        
        var suspendText = Globals.textSuspend//"Suspend"//"Will\nStudy"
        var pendingText = Globals.textPending//"Will\nStudy"
//        let knownText = "Known"
        let studyText = Globals.textStudy
        
//        if card.enabled.boolValue {
//            addText = "Study"
//        }
        
        let studyColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
        let pendingColor = UIColor(
            red: 102.0 / 255.0,
            green: 204.0 / 255.0,
            blue: 255.0 / 255.0,
            alpha: 1)
        let suspendColor = UIColor(
            red: 255.0 / 255.0,
            green: 102.0 / 255.0,
            blue: 102.0 / 255.0,
            alpha: 1)
        var leftText = ""
//        var rightText = ""
        var leftColor = UIColor()
//        var rightColor = UIColor()
        
        switch type {
        case .Suspended:
            leftText = suspendText
//            rightText = addText
            
            leftColor = suspendColor
//            rightColor = addColor
        case .Pending:
            leftText = pendingText
//            rightText = addText
            
            leftColor = pendingColor
//            rightColor = addColor
            break
        case .Studying:
            leftText = studyText
//            rightText = knownText
            
            leftColor = studyColor
//            rightColor = knownColor
            break
        }
        
        leftButton.setTitle(leftText, forState: .Normal)
//        rightButton.setTitle(rightText, forState: .Normal)
        
        leftButton.setTitleColor(adjustToForegroundColor(leftColor), forState: .Normal)
//        rightButton.setTitleColor(adjustToForegroundColor(rightColor), forState: .Normal)
        
        leftButton.backgroundColor = adjustToBackgroundColor(leftColor)
//        rightButton.backgroundColor = adjustToBackgroundColor(rightColor)
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