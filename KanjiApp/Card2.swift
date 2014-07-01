////
////  Card.swift
////  KanjiApp
////
////  Created by Sky on 2014-06-24.
////  Copyright (c) 2014 Sky. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class Card {
//    init(kanji: String, index: Int, hiragana: String, definition: String, exampleEnglish: String, exampleJapanese: String, soundWord: String, soundDefinition: String, definitionOther: String, usageAmount: Int, usageAmountOther: Int, pitchAccentText: String, pitchAccent: Int, otherExampleSentences: String) {
//        self.kanji = kanji
//        self.index = index
//        self.hiragana = hiragana
//        self.definition = definition
//        self.exampleEnglish = exampleEnglish
//        self.exampleJapanese = exampleJapanese
//        self.soundWord = soundWord
//        self.soundDefinition = soundDefinition
//        self.definitionOther = definitionOther
//        self.usageAmount = usageAmount
//        self.usageAmountOther = usageAmountOther
//        self.pitchAccentText = pitchAccentText
//        self.pitchAccent = pitchAccent
//        self.otherExampleSentences = otherExampleSentences
//        
//        self.interval = 0.0
//        self.font = "Helvetica"
//        self.answersEasy = 0
//        self.answersNormal = 0
//        self.answersHard = 0
//        self.answersForgot = 0
//    }
//    
//    let kanji = ""
//    let index = 0 
//    let hiragana = ""
//    let definition = ""
//    let exampleEnglish = ""
//    let exampleJapanese = ""
//    let soundWord = ""
//    let soundDefinition = ""
//    let definitionOther = ""
//    let usageAmount = 0
//    let usageAmountOther = 0
//    let pitchAccentText = ""
//    let pitchAccent = 0
//    let otherExampleSentences = ""
//    
//    //let definition = ""
//    
//    var answersEasy = 0
//    var answersNormal = 0
//    var answersHard = 0
//    var answersForgot = 0
//    var interval = 0.0
//    let font = ""
//    
//    var front: NSAttributedString {
//    get {
//        var value = NSMutableAttributedString()
//        
//        value.beginEditing()
//        
//        for char in kanji
//        {
//            value.addAttributedText(char + "", NSFontAttributeName, UIFont(name: font, size: 140))
//        }
//        
//        value.endEditing()
//        
//        return value
//    }
//    }
//    
//    var back: NSAttributedString {
//    get {
//        var value = NSMutableAttributedString()
//        
//        value.beginEditing()
//        
//        value.addAttributedText(hiragana, NSFontAttributeName, UIFont(name: font, size: 50))
//        
//        value.addBreak(5)
//        
//        value.addAttributedText(definition, NSFontAttributeName, UIFont(name: font, size: 22))
//        
//        value.addBreak(20)
//        
//        value.addAttributedText(exampleJapanese, NSFontAttributeName, UIFont(name: font, size: 24), processAttributes: true)
//        
//        value.addBreak(5)
//        
//        value.addAttributedText(exampleEnglish, NSFontAttributeName, UIFont(name: font, size: 16))
//        
//        value.addBreak(10)
//        
//        value.addAttributedText("\(pitchAccent)", NSFontAttributeName, UIFont(name: font, size: 16))
//        
//        //'#000000', '#CC0066', '#0099EE', '#11AA00', '#FF6600', '#990099', '#999999', '#000000', '#000000', '#000000'
//        
//        var color = colorForPitchAccent(pitchAccent)
//        
//        value.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, value.mutableString.length))
//        
//        
//        value.endEditing()
//        
//        return value
//    }
//    }
//    
//    func colorForPitchAccent(pitchAccent: Int) -> UIColor
//    {
//        var color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        
//        switch pitchAccent {
//        case 1:
//            color = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)
//            
//        case 2:
//            color = UIColor(red: 0, green: 0.5625, blue: 0.9375, alpha: 1)
//            
//        case 3:
//            color = UIColor(red: 1.0 / 16.0, green: 1.0 / 11.0, blue: 0, alpha: 1)
//            
//        case 4:
//            color = UIColor(red: 1, green: 6.0 / 16.0, blue: 0, alpha: 1)
//            
//        case 5:
//            color = UIColor(red: 9.0 / 16.0, green: 0, blue: 9.0 / 16.0, alpha: 1)
//            
//        case 6:
//            color = UIColor(red: 9.0 / 16.0, green: 9.0 / 16.0, blue: 9.0 / 16.0, alpha: 1)
//            
//        default:
//            color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        }
//        
//        return color
//    }
//}
//
//extension NSMutableAttributedString {
//    func addBreak(size: CGFloat)
//    {
//        if(size > 0)
//        {
//            self.addAttributedText(" ", NSFontAttributeName, UIFont(name: "Helvetica", size: size));
//        }
//    }
//    
//    func addAttributedText(var text: String, _ attributeName: String, _ object: AnyObject, breakLine: Bool = true, processAttributes: Bool = false)
//    {
//        var bolds: NSRange[] = []
//        
//        if processAttributes
//        {
//            var furiganaOpen = text.componentsSeparatedByString("]")
//            
//            text = ""
//            for item in furiganaOpen
//            {
//                text += item.componentsSeparatedByString("[")[0]
//            }
//            
//            text = removeFromString(text, "<b>")
//            text = removeFromString(text, "</b>")
//            text = removeFromString(text, " ")
//        }
//        
//        if breakLine
//        {
//            text += "\n"
//        }
//        
//        var existingLength: Int = self.mutableString.length
//        var range: NSRange = NSMakeRange(existingLength, countElements(text))
//        self.mutableString.appendString(text)
//        self.addAttribute(attributeName, value: object, range: range)
//    }
//    
//    func removeFromString(var value: String, _ remove: String) -> String
//    {
//        var items = value.componentsSeparatedByString(remove)
//        
//        value = ""
//        for item in items
//        {
//            value += item
//        }
//        
//        return value
//    }
//}
//
