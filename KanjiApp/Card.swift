import UIKit
import CoreData

@objc(Card)
class Card: NSManagedObject {
    @NSManaged var kanji: String
    @NSManaged var index: NSNumber
    @NSManaged var hiragana: String
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var interval: NSNumber
    @NSManaged var dueTime: NSNumber
    @NSManaged var enabled: NSNumber
    @NSManaged var suspended: NSNumber
    @NSManaged var known: NSNumber
    @NSManaged var definition: String
    @NSManaged var usageAmount: NSNumber
    @NSManaged var isKanji: NSNumber
    @NSManaged var embeddedData: CardData
    
    func answerCard(difficulty: AnswerDifficulty) {
        
//        managedObjectContext.undoManager. = "answer card"
        managedObjectContext.undoManager.beginUndoGrouping()
        
        let secondsSince1970 = Globals.secondsSince1970
        let adjustInterval = dueTime < secondsSince1970
        
//        println("dueTime \(dueTime)")
        
        switch difficulty {
        case .Easy:
//            println("Easy")
            if adjustInterval {
                interval = 10
            }
            embeddedData.answersKnown = embeddedData.answersKnown + 1
        case .Normal:
//            println("Normal")
            if adjustInterval {
                if interval.doubleValue < 11 {
                    interval = interval.doubleValue + 1
                }
            }
            
            embeddedData.answersNormal = embeddedData.answersNormal + 1
        case .Hard:
            if adjustInterval {
                if interval.doubleValue >= 6 {
                    interval = interval.doubleValue - 0.5
                }
            }
            
            embeddedData.answersHard = embeddedData.answersHard + 1
        case .Forgot:
            if adjustInterval {
                interval = interval.doubleValue - 4
            }
            embeddedData.answersForgot = embeddedData.answersForgot + 1
        }
        
        interval = min(11, interval.doubleValue)
        interval = max(0, interval.doubleValue)
        
        dueTime = secondsSince1970 + timeForInterval()
//        dueTime = timeForInterval()
        
//        println("newDueTime \(dueTime)")
        
//        println("timeForInterval \(timeForInterval())")
//        println("dueTime \(dueTime)")
        //        println("secondsSince1970 \(secondsSince1970)")
        managedObjectContext.undoManager.endUndoGrouping()
    }
    
    /// In seconds
    func timeForInterval() -> Double {
        var small = timeForIntervalSimple(Int(interval.doubleValue))
        var large = timeForIntervalSimple(Int(interval.doubleValue) + 1)
        
        var diff = large - small
        var percent = interval.doubleValue % 1
        diff *= percent
        
        return small + diff
    }
    
    func timeForIntervalSimple(value: Int) -> Double {
        
        let min: Double = 60.0
        let hour: Double = 60.0 * 60.0
        let day: Double = hour * 24.0
        let month: Double = day * (365.0 / 12.0)
        let year: Double = day * 365.0
        
        switch value {
        case 0:
            return 0
        case 1:
            return 5
        case 2:
            return 25
        case 3:
            return 2 * min
        case 4:
            return 10 * min
        case 5:
            return 60 * min
        case 6:
            return 5 * hour
        case 7:
            return day
        case 8:
            return 5 * day
        case 9:
            return 25 * day
        case 10:
            return 4 * month
        case 11:
            return 2 * year
        case 12:
            return 3 * year
        case 13:
            return 4 * year
        default:
            return 0
        }
    }
    
    var verticalKanji: String {
    get {
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
        
        return setText
    }
    }
    
    func animatedLabelText(size: CGFloat) -> NSAttributedString {
    let font = Globals.JapaneseFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
//        let size: CGFloat = 30
    
        value.addAttributedText(verticalKanji, [(NSFontAttributeName, UIFont(name: font, size: size))])
        value.endEditing()
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.paragraphSpacing = -size / 3.0
        
        value.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, value.mutableString.length))
//        addBody(value, font)
        
        return value
    }
    
//    func setFrontTextFont(label: UILabel) -> UIFont {
//    }
    
    var front: NSAttributedString {
        get {
        
        let font = Globals.DefaultFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
            
        let baseSize: CGFloat = 250
        
        var size = baseSize * 2 / CGFloat(countElements(kanji))
        
        if size > baseSize {
            size = baseSize
        }
            
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
            
        let fontPair: (String, AnyObject) = (NSFontAttributeName, UIFont(name: font, size: size))
        let paragraph: (String, AnyObject) = (NSParagraphStyleAttributeName, paragraphStyle)
            
        value.addAttributedText(verticalKanji, [fontPair, paragraph])
        value.endEditing()
        
        return value
    }
    }
    
    var back: NSAttributedString {
    get {
        let font = Globals.JapaneseFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        // scroll up kanji
        let baseSize: CGFloat = 80
        
        var size = baseSize * 3 / CGFloat(countElements(kanji))
        
        if size > baseSize {
            size = baseSize
        }
        
        value.addAttributedText(kanji, [(NSFontAttributeName, UIFont(name: Globals.DefaultFont, size: size))])
        
        // main text
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
        
        var entity = managedObjectContext.fetchCardByIndex(index)
        
        addTo.addAttributedText(definition, [(NSFontAttributeName, UIFont(name: fontName, size: 22))])
        
        addTo.addBreak(20)
        
        addTo.addAttributedText(embeddedData.exampleJapanese, [(NSFontAttributeName, UIFont(name: fontName, size: 24))], processAttributes: true, removeSpaces: true)
        
        addTo.addBreak(5)
        
        addTo.addAttributedText(embeddedData.exampleEnglish, [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addBreak(30)
        
        addExampleSentences(addTo, fontName)
        
        addTo.addBreak(10)
        
        addTo.addAttributedText("\(embeddedData.pitchAccent)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        addTo.addBreak(10)
        
        addTo.addAttributedText("JLPT \(jlptLevel)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        // Debug
        
        addTo.addBreak(10)
        
        addTo.addAttributedText("Interval \(interval.doubleValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addAttributedText("Answers Normal  \(embeddedData.answersNormal.integerValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addAttributedText("Answers Hard \(embeddedData.answersHard.integerValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addAttributedText("Answers Forgot \(embeddedData.answersForgot.integerValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addAttributedText("Due Time \(dueTime.doubleValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        // End Debug
        
//        var color = 
        
        addTo.addAttribute(NSForegroundColorAttributeName, value: pitchAccentColor(), range: NSMakeRange(0, addTo.mutableString.length))
    }
    
    func addExampleSentences(addTo: NSMutableAttributedString, _ fontName: String) {
        var validChars = NSCharacterSet(range: NSRange(location: 32, length: 127))
        var isJapanese = true
        var text = ""
        
        var examples: String  = embeddedData.otherExampleSentences.removeTagsFromString(embeddedData.otherExampleSentences)
        
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
//        
        value.addAttributedText(definition, [(NSFontAttributeName, UIFont(name: font, size: CGFloat(12))), (NSForegroundColorAttributeName, definitionColor)])
        
//        value.addAttributedText("\(usageAmount)", [(NSFontAttributeName, UIFont(name: font, size: CGFloat(12))), (NSForegroundColorAttributeName, definitionColor)])
        
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
    
    func pitchAccentColor() -> UIColor {
        return caculateColorForPitchAccent(embeddedData.pitchAccent.integerValue)
    }

    func caculateColorForPitchAccent(pitchAccent: Int) -> UIColor {
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
    
    func listColor() -> UIColor {
        if suspended.boolValue {
            return Globals.colorLists
        } else if known.boolValue {
            return Globals.colorKnown
        }
        
        return Globals.colorMyWords
    }
    
    func listName() -> String {
        if suspended.boolValue {
            return "Not Studied"
        } else if known.boolValue {
            return "Known"
        } else if enabled.boolValue {
            return "Studying"
        }
        
        return "Will Study"
    }
}