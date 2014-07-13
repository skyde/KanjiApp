extension String
{
    func removeTagsFromString(var text: String) -> String
    {
        var furiganaOpen = text.componentsSeparatedByString("]")
        
        text = ""
        for item in furiganaOpen
        {
            text += item.componentsSeparatedByString("[")[0]
        }
        
        text = removeFromString(text, "<b>")
        text = removeFromString(text, "</b>")
        text = removeFromString(text, "</span>")
        text = removeFromString(text, "<span style=\"font-size:20px\">")
        text = replaceInString(text, "<br>", "")
        text = replaceInString(text, "&#39;", "'")
        text = replaceInString(text, "&quot;", "\"")
        text = replaceInString(text, "&nbsp;", "\"")
        
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