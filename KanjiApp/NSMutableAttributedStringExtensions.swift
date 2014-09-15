import UIKit
import CoreData

extension NSMutableAttributedString {
    func addBreak(size: CGFloat)
    {
        if(size > 0)
        {
            self.addAttributedText(" ", [(NSFontAttributeName, UIFont(name: "Helvetica", size: size))]);
        }
    }
    
    func addAttributedText(var text: String, var _ attributeAndValues: [(String, AnyObject)], breakLine: Bool = true, processAttributes: Bool = false, removeSpaces: Bool = false, removeFurigana: Bool? = nil)
    {
        var bolds: [NSRange] = []
        
        if removeSpaces
        {
            text = text.removeFromString(text, " ")
        }
        
        if breakLine
        {
            text += "\n"
        }
        
        if processAttributes
        {
            text = text.removeTagsFromString(text, removeFurigana: removeFurigana ?? processAttributes)
        }
        
        var existingLength: Int = self.mutableString.length
        var range: NSRange = NSMakeRange(existingLength, countElements(text))
        self.mutableString.appendString(text)
        
        for pair in attributeAndValues
        {
            self.addAttribute(pair.0, value: pair.1, range: range)
        }
    }
}