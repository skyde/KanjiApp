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
    
    /// name setText is not allowed
    func setTextValue(value: String) {
        if value == "" {
            setDefaultText(true)
        } else {
            setDefaultText(false)
            text = value
        }
        
        if let onTextDidChange = onTextDidChange {
            onTextDidChange()
        }
    }
    
    func setDefaultText(value: Bool) {
        defaultTextShown = value
        
        if defaultTextShown {
            text = defaultText
            textColor = defaultTextColor
        } else {
            text = ""
            textColor = internalTextColor
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultText(true)
        
        delegate = self
    }
    
    public func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
        if defaultTextShown {
            setDefaultText(false)
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
            setDefaultText(true)
        }
        return true
    }
}