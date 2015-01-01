import UIKit
import CoreData

extension String
{
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func isPrimarilyKanji() -> Bool
    {        
//        var validChars = NSCharacterSet(range: NSRange(location: 0x4e00, length: 0x9fbf-0x4e00))

        return componentsSeparatedByCharactersInSet(Globals.kanjiCharacterSet).count > 1
    }
    
    func asKana() -> String {
        var returnValue: String = ""
        
        var addedSpace = true
        for item in self.componentsSeparatedByCharactersInSet(Globals.allKanaCharacterSet.invertedSet) {
//            if item == " " {
//                continue
//            }
            var add = item//replaceInString(item, " ", "aaa")
            
            if !addedSpace {
//                returnValue += " "
                addedSpace = true
            }
            
            if countElements(add) > 0 {
                addedSpace = false
            }
            returnValue += add
        }
        
        return returnValue
    }
    
    func removeTagsFromString(var text: String, removeFurigana: Bool = true) -> String
    {
        if removeFurigana {
            var furiganaOpen = text.componentsSeparatedByString("]")
            
            text = ""
            for item in furiganaOpen
            {
                text += item.componentsSeparatedByString("[")[0]
            }
        }
        
        text = removeFromString(text, "<b>")
        text = removeFromString(text, "</b>")
        text = removeFromString(text, "</span>")
        text = removeFromString(text, "<span style=\"font-size:20px\">")
        text = replaceInString(text, "<br>", "")
        text = replaceInString(text, "&#39;", "'")
        text = replaceInString(text, "&quot;", "\"")
        text = replaceInString(text, "&nbsp;", "\"")
        text = replaceInString(text, "<br />", "\n")
        
        return text
    }
    
    func removeFromString(var value: String, _ remove: String) -> String
    {
        var items = value.componentsSeparatedByString(remove)
        
        value = ""
        for item in items
        {
            value += item
        }
        
        return value
    }
    
    func replaceInString(var value: String, _ remove: String, _ newValue: String) -> String
    {
        var items = value.componentsSeparatedByString(remove)
        
        value = ""
        var spacer = ""
        for item in items
        {
            value += spacer + item
            spacer = newValue
        }
        
        return value
    }
}