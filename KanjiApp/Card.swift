import UIKit
import CoreData

@objc(Card)
class Card: NSManagedObject {
    @NSManaged var kanji: String
    @NSManaged var index: NSNumber
    @NSManaged var hiragana: String
    @NSManaged var definition: String
    @NSManaged var exampleEnglish: String
    @NSManaged var exampleJapanese: String
    @NSManaged var soundWord: String
    @NSManaged var soundDefinition: String
    @NSManaged var definitionOther: String
    @NSManaged var usageAmount: NSNumber
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var pitchAccentText: String
    @NSManaged var pitchAccent: NSNumber
    @NSManaged var otherExampleSentences: String

    @NSManaged var answersKnown: NSNumber
    @NSManaged var answersNormal: NSNumber
    @NSManaged var answersHard: NSNumber
    @NSManaged var answersForgot: NSNumber
    @NSManaged var interval: NSNumber
    @NSManaged var dueTime: NSNumber
    @NSManaged var enabled: NSNumber
    @NSManaged var suspended: NSNumber
    
    func answerCard(difficulty: AnswerDifficulty) {
        switch difficulty {
        case .Easy:
            println("Easy")
            interval = 9
        case .Normal:
            println("Normal")
            if interval.integerValue < 12 {
                interval = interval.doubleValue + 1
            }
        case .Hard:
            println("Hard")
            if interval.integerValue >= 1 {
                interval = interval.doubleValue - 1
            }
        case .Forgot:
            println("Forgot")
            interval = interval.doubleValue / 2
            
        }
    }
    
//    var front: NSAttributedString {
//    get {
//    }
//    }
    
    func setFrontText(label: UILabel) {
        
        var value = NSMutableAttributedString()
        
        let baseSize: Double = 250
        
        var size = baseSize * 2 / Double(countElements(kanji))
        
        if size > baseSize {
            size = baseSize
        }
        
        var setText = ""
        var spacing = ""
        for char in kanji {
            var add = char
            if add == "ー" {
                add = "丨"
            }
            setText += "\(spacing)\(add)"
            spacing = "\n"
        }
        
        label.font = label.font.fontWithSize(CGFloat(size))
        label.text = setText
    }
    
    var back: NSAttributedString {
    get {
        let font = Globals.JapaneseFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        value.addAttributedText(hiragana, [(NSFontAttributeName, UIFont(name: font, size: 50))])
        value.endEditing()
        
        addBody(value, font)
        
        return value
    }
    }
    
    var definitionAttributedText: NSAttributedString {
    get {
        let font = Globals.JapaneseFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        value.addAttributedText(kanji, [(NSFontAttributeName, UIFont(name: font, size: 50))])
        value.endEditing()
        value.addAttributedText(hiragana, [(NSFontAttributeName, UIFont(name: font, size: 30))])
        value.endEditing()
        
        addBody(value, font)
        
        return value
    }
    }
    
    func addBody(addTo: NSMutableAttributedString, _ fontName: String) {
        
        addTo.addBreak(5)
        
        addTo.addAttributedText(definition, [(NSFontAttributeName, UIFont(name: fontName, size: 22))])
        
        addTo.addBreak(20)
        
        addTo.addAttributedText(exampleJapanese, [(NSFontAttributeName, UIFont(name: fontName, size: 24))], processAttributes: true, removeSpaces: true)
        
        addTo.addBreak(5)
        
        addTo.addAttributedText(exampleEnglish, [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addBreak(30)
        
        addExampleSentences(addTo, fontName)
        
        addTo.addBreak(10)
        
        addTo.addAttributedText("\(pitchAccent)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        var color = colorForPitchAccent(Int(pitchAccent))
        
        addTo.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, addTo.mutableString.length))
    }
    
    func addExampleSentences(addTo: NSMutableAttributedString, _ fontName: String) {
        var validChars = NSCharacterSet(range: NSRange(location: 32, length: 127))
        var isJapanese = true
        var text = ""
        
        var examples: String  = otherExampleSentences.removeTagsFromString(otherExampleSentences)
        
        for item in examples {
            var test = String(item).componentsSeparatedByCharactersInSet(validChars)[0]
            var isCurrentJapanese = test != ""
            
            if isJapanese != isCurrentJapanese &&
                text != "" &&
                item != " " &&
                item != "　" &&
                item != "-" &&
                item != "(" &&
                item != ")" &&
                item != "0" &&
                item != "1" &&
                item != "2" &&
                item != "3" &&
                item != "4" &&
                item != "5" &&
                item != "6" &&
                item != "7" &&
                item != "8" &&
                item != "9" {
                    if countElements(text) > 1 {
                        var size: CGFloat = isJapanese ? 24 : 16
                        var removeSpaces = isJapanese ? true : false
                        var extraSpace: String = isJapanese ? "" : "\n"
                        
                        addTo.addAttributedText(text + "\n" + extraSpace, [(NSFontAttributeName, UIFont(name: fontName, size: size))], processAttributes: true, removeSpaces: removeSpaces, breakLine: false)
                        
                        text = ""
                    }
                    isJapanese = !isJapanese
            }
            
            if !(text == "" && item == ".") {
                text += item
            }
        }
    }
    
    
    var cellText: NSAttributedString {
    get {
        let font = "HiraKakuProN-W3"
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        value.addAttributedText(kanji + " ", [(NSFontAttributeName, UIFont(name: font, size: CGFloat(25)))], breakLine: false)
        
        var hiraganaColor = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)
        
        value.addAttributedText(hiragana + " ", [(NSFontAttributeName, UIFont(name: font, size: CGFloat(16))), (NSForegroundColorAttributeName, hiraganaColor)], breakLine: false)
        
        var definitionColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        value.addAttributedText(definition, [(NSFontAttributeName, UIFont(name: font, size: CGFloat(12))), (NSForegroundColorAttributeName, definitionColor)])
        
        value.endEditing()
        
        return value
    }
    }

//    func getAsciiCharacterSet() -> NSCharacterSet
//    {
//        return NSCharacterSet.alphanumericCharacterSet()
////        var asciiCharacters = NSMutableString(string)
////        for NSInteger i = 32; i < 127; i++  {
////            asciiCharacters.appendFormat("%c", i)
////        }
////        
////        var nonAsciiCharacterSet = NSCharacterSet()
////        
////        test = [[test componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
////        
////        NSLog(@"%@", test);
//    }

    func colorForPitchAccent(pitchAccent: Int) -> UIColor {
        var color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

        switch pitchAccent {
        case 1:
            color = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)

        case 2:
            color = UIColor(red: 0, green: 0.5625, blue: 0.9375, alpha: 1)

        case 3:
            color = UIColor(red: 1.0 / 16.0, green: 1.0 / 11.0, blue: 0, alpha: 1)

        case 4:
            color = UIColor(red: 1, green: 6.0 / 16.0, blue: 0, alpha: 1)

        case 5:
            color = UIColor(red: 9.0 / 16.0, green: 0, blue: 9.0 / 16.0, alpha: 1)

        case 6:
            color = UIColor(red: 9.0 / 16.0, green: 9.0 / 16.0, blue: 9.0 / 16.0, alpha: 1)

        default:
            color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }

        return color
    }
}