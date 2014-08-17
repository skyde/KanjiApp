import Foundation
import UIKit

@IBDesignable
public class CustomUITextView : UITextView, UITextViewDelegate {
    
    @IBInspectable var defaultText: String = ""
    @IBInspectable var defaultTextColor: UIColor = UIColor(white: 180 / 255.0, alpha: 1)
    
    public var internalText: String {
        get {
            if defaultTextShown {
                return ""
            }
            
            return text
        }
    }
    var internalTextFont: UIFont = UIFont(name: Globals.JapaneseFontLight, size: 24)
    var internalTextColor: UIColor = UIColor(white: 65.0 / 255.0, alpha: 1)
    
    public var defaultTextShown = true
    
    var onTextDidChange: (() -> ())?
    
//    public required init(coder aDecoder: NSCoder!) {
//        super.init(coder: aDecoder)
//        
//        println("init")
//        println(defaultText)
//        
//    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        text = defaultText
        textColor = defaultTextColor
        defaultTextShown = true
        
        delegate = self
    }
    
    public func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
        
        if defaultTextShown {
            text = ""
            textColor = internalTextColor
            defaultTextShown = false
        }
        
        return true
    }
    
    public func textViewDidChange(textView: UITextView!) {
        if let onTextDidChange = onTextDidChange {
            onTextDidChange()
        }
    }
    
    public func textViewShouldEndEditing(textView: UITextView!) -> Bool {
        
        if text == "" {
            text = defaultText
            textColor = defaultTextColor
            defaultTextShown = true
        }
        return true
    }
}