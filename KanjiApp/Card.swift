import UIKit
import CoreData

@objc(Card)
class Card: NSManagedObject {
    @NSManaged var kanji: String
    @NSManaged var index: NSNumber
    @NSManaged var hiragana: String
    @NSManaged var usageAmount: NSNumber
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var answersKnown: NSNumber
    @NSManaged var answersNormal: NSNumber
    @NSManaged var answersHard: NSNumber
    @NSManaged var answersForgot: NSNumber
    @NSManaged var interval: NSNumber
    @NSManaged var dueTime: NSNumber
    @NSManaged var enabled: NSNumber
    @NSManaged var suspended: NSNumber
    @NSManaged var known: NSNumber
    @NSManaged var embeddedData: CardData
    
    func answerCard(difficulty: AnswerDifficulty) {
        let secondsSince1970 = Globals.secondsSince1970
        let adjustInterval = dueTime < secondsSince1970
        
        println("dueTime \(dueTime)")
        
        switch difficulty {
        case .Easy:
            println("Easy")
            if adjustInterval {
                interval = 10
            }
            answersKnown = answersKnown + 1
        case .Normal:
            println("Normal")
            if interval.integerValue < 10 {
                interval = interval.integerValue + 1
            }
            if adjustInterval {
                answersNormal = answersNormal + 1
            }
        case .Hard:
            println("Hard")
            if interval.integerValue >= 1 {
                interval = interval.integerValue - 1
            }
            if adjustInterval {
                answersHard = answersHard + 1
            }
        case .Forgot:
            println("Forgot")
            interval = 0
            if adjustInterval {
                answersForgot = answersForgot + 1
            }
        }
        
        interval = min(10, interval.integerValue)
        interval = max(0, interval.integerValue)
        
        dueTime = secondsSince1970 + timeForInterval()
//        dueTime = timeForInterval()
        
        println("newDueTime \(dueTime)")
        
//        println("timeForInterval \(timeForInterval())")
//        println("dueTime \(dueTime)")
//        println("secondsSince1970 \(secondsSince1970)")
    }
    
    
    /// In seconds
    func timeForInterval() -> Double {
        
        let min: Double = 60.0
        let hour: Double = 60.0 * 60.0
        let day: Double = hour * 24.0
        let month: Double = day * (365.0 / 12.0)
        let year: Double = day * 365.0
        
        switch interval.integerValue {
        case 0:
            return 5
        case 1:
            return 25
        case 2:
            return 2 * min
        case 3:
            return 10 * min
        case 4:
            return 60 * min
        case 5:
            return 5 * hour
        case 6:
            return day
        case 7:
            return 5 * day
        case 8:
            return 25 * day
        case 9:
            return 4 * month
        case 10:
            return 2 * year
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
    
    func setFrontText(label: UILabel) {
        
        var value = NSMutableAttributedString()
        
        let baseSize: Double = 250
        
        var size = baseSize * 2 / Double(countElements(kanji))
        
        if size > baseSize {
            size = baseSize
        }
        
        label.font = label.font.fontWithSize(CGFloat(size))
        label.text = verticalKanji
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
        
        var entity = managedObjectContext.fetchCardByIndex(index)
        
        addTo.addAttributedText(embeddedData.definition, [(NSFontAttributeName, UIFont(name: fontName, size: 22))])
        
        addTo.addBreak(20)
        
        addTo.addAttributedText(embeddedData.exampleJapanese, [(NSFontAttributeName, UIFont(name: fontName, size: 24))], processAttributes: true, removeSpaces: true)
        
        addTo.addBreak(5)
        
        addTo.addAttributedText(embeddedData.exampleEnglish, [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
        addTo.addBreak(30)
        
        addExampleSentences(addTo, fontName)
        
        addTo.addBreak(10)
        
        addTo.addAttributedText("\(embeddedData.pitchAccent)", [(NSFontAttributeName, UIFont(name: fontName, size: 16))])
        
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
        
        value.addAttributedText(embeddedData.definition, [(NSFontAttributeName, UIFont(name: font, size: CGFloat(12))), (NSForegroundColorAttributeName, definitionColor)])
        
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
}