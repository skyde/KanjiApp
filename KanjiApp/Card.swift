//
//  Card.swift
//  KanjiApp
//
//  Created by Sky on 2014-06-24.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

class Card {
    init(_ kanji: String, _ hiragana: String, _ definition: String, _ exampleEnglish: String, _ exampleJapanese: String, _ pitchAccent: Int) {
        self.kanji = kanji;
        self.hiragana = hiragana;
        self.definition = definition;
        self.exampleEnglish = exampleEnglish;
        self.exampleJapanese = exampleJapanese;
        self.pitchAccent = pitchAccent;
        
        self.interval = 0.0
        self.font = "Helvetica";
    }
    
    let kanji = ""
    let hiragana = ""
    let definition = ""
    let exampleEnglish = ""
    let exampleJapanese = ""
    let pitchAccent = 0
    
    var interval = 0.0
    let font = ""
    
    var front: NSAttributedString {
    get {
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        for char in kanji
        {
            value.addAttributedText(char + "", NSFontAttributeName, UIFont(name: font, size: 140))
        }
        
        value.endEditing()
        
        return value
    }
    }
    
    var back: NSAttributedString {
    get {
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        value.addAttributedText(hiragana, NSFontAttributeName, UIFont(name: font, size: 60))
        
        value.addBreak(5)
        
        value.addAttributedText(definition, NSFontAttributeName, UIFont(name: font, size: 20))
        
        value.addBreak(15)
        
        value.addAttributedText(exampleJapanese, NSFontAttributeName, UIFont(name: font, size: 24))
        
        value.addBreak(5)
        
        value.addAttributedText(exampleEnglish, NSFontAttributeName, UIFont(name: font, size: 16))
        
        value.addBreak(10)
        
        //'#000000', '#CC0066', '#0099EE', '#11AA00', '#FF6600', '#990099', '#999999', '#000000', '#000000', '#000000'
        
        var color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        switch pitchAccent
        {
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
        
        value.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, value.mutableString.length))
        
        
        value.endEditing()
        
        return value
    }
    }
}

extension NSMutableAttributedString {
    func addBreak(size: CGFloat)
    {
        if(size > 0)
        {
            self.addAttributedText(" ", NSFontAttributeName, UIFont(name: "Helvetica", size: size));
        }
    }
    
    func addAttributedText(var text: String, _ attributeName: String, _ object: AnyObject, breakLine: Bool = true)
    {
        if breakLine
        {
            text += "\n"
        }
        
        var existingLength: Int = self.mutableString.length
        var range: NSRange = NSMakeRange(existingLength, countElements(text))
        self.mutableString.appendString(text)
        self.addAttribute(attributeName, value: object, range: range)
    }
}

