import UIKit
import CoreData

extension NSMutableAttributedString {
    func addBreak(size: CGFloat)
    {
        if(size > 0)
        {
            self.addAttributedText(" ", NSFontAttributeName, UIFont(name: "Helvetica", size: size));
        }
    }
    
    func addAttributedText(var text: String, _ attributeName: String, _ object: AnyObject, breakLine: Bool = true, processAttributes: Bool = false, removeSpaces: Bool = false)
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
            
            text = text.removeTagsFromString(text)
            
            //            {
            //                var broken = sentence.componentsSeparatedByString("")
            //
            //            var spanSizeOpen = text.componentsSeparatedByString("<span style=\"font-size:20px\">")
            //            text = ""
            //
            //            for item in spanSizeOpen
            //            {
            //                var itemSplit = item.componentsSeparatedByString("</span>")
            //
            //                for var i = 0; i < countElements(itemSplit); i++
            //                {
            //                    var previousSize = countElements(text)
            //                    text += itemSplit[i]
            //
            //                    if i == 0
            //                    {
            //                        var color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            //
            //                        println(self.mutableString)
            //
            //                        var range: NSRange = NSMakeRange(self.mutableString.length, 2)
            //                        self.addAttribute(NSBackgroundColorAttributeName, value: color, range: range)
            //                    }
            //                }
            //            }
        }
        
        var existingLength: Int = self.mutableString.length
        var range: NSRange = NSMakeRange(existingLength, countElements(text))
        self.mutableString.appendString(text)
        
        self.addAttribute(attributeName, value: object, range: range)
    }
}