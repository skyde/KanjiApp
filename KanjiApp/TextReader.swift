//
//  TextReader.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-06.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreText

class TextReader: CustomUIViewController, UITextViewDelegate {
    @IBOutlet var userText : CustomUITextView!
    var tokens: [TextToken] = []
    
    @IBOutlet weak var addAll: UIButton!
    @IBOutlet weak var translate: UIButton!
    @IBOutlet weak var edit: UIButton!
    
    var onTouchGesture: UITapGestureRecognizer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tokens = []
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        onTouchGesture = UITapGestureRecognizer(target: self, action: "onTouch:")
        
        userText.onTextDidChange = {
            self.translate.enabled = !(self.userText.text == "" || self.userText.defaultTextShown)
            
            self.settings.readerText = self.userText.internalText
            
            self.saveContext()
        }
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "closeKeyboard", object: nil)
    }
    
    func closeKeyboard() {
        userText.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userText.scrollRangeToVisible(NSRange(location: 0, length: 1))
        
        setState(false)
        
        userText.setTextValue(settings.readerText)
    }
    
    @IBAction func addAllTap(sender: AnyObject) {
        var add: [Int] = []
        
        for token in tokens {
            if token.hasDefinition {
                add.append(token.index)
            }
        }
        
        Globals.notificationTransitionToView.postNotification(.Lists(
            title: "Words to Add",
            color: Globals.colorFunctions,
            cards: add,
            displayConfirmButton: true,
            displayAddButton: false,
            sourceList: nil,
            enableOnAdd: false))
    }
    
    @IBAction func translateTap(sender: AnyObject) {
        if !userText.defaultTextShown && userText.text != "" {
            setState(true)
        }
    }
    
    @IBAction func editTap(sender: AnyObject) {
        setState(false)
    }
    
    @IBAction func addAll(sender: AnyObject) {
        for token in tokens {
            if var card = managedObjectContext.fetchCardByIndex(token.index) {
                card.enabled = true
            }
        }
        saveContext()
    }
    
    @IBAction func onTranslate(sender: AnyObject) {
        tokenizeText()
    }
    
    func setState(showTranslation: Bool) {
        
        addAll.hidden = !showTranslation
        edit.hidden = !showTranslation
        translate.hidden = showTranslation
        userText.editable = !showTranslation
//        touchArea.hidden = !showTranslation
        
        if showTranslation {
            tokenizeText()
            userText.addGestureRecognizer(onTouchGesture)
        } else {
            userText.removeGestureRecognizer(onTouchGesture)
            
            if userText.internalText != "" {
                userText.text = userText.internalText
                userText.textColor = userText.internalTextColor
            }
        }
    }
    
    func formatDisplay() {
        var value = NSMutableAttributedString()
        value.beginEditing()
        
        for token in tokens {
            var color = userText.internalTextColor
            if token.hasDefinition {
                color = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)
            }
            
            let fontAttribute: (String, AnyObject) = (NSFontAttributeName, userText.internalTextFont)
            let colorAttribute: (String, AnyObject) = (NSForegroundColorAttributeName, color)
            var hasDefinition: (String, AnyObject) = ("hasDefinition", token.index)
            
            var attributes = [fontAttribute, colorAttribute, hasDefinition]
            
            value.addAttributedText(token.text, attributes, breakLine: false)
        }
        
        value.endEditing()
        
        userText.attributedText = value
    }
    
    func tokenizeText() {
        tokens = []
        
        let textNS:NSString = userText.text as NSString
        let textCF:CFString = textNS as CFString
        let length = textNS.length
        
        let tokenizer = CFStringTokenizerCreate(nil, textCF, CFRangeMake(0, length), 0, CFLocaleCreate(nil, "ja_JP"))
        
        var lastRangeMax: CFIndex = 0
        while CFStringTokenizerAdvanceToNextToken(tokenizer) != .None {
            
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            var subString = CFStringCreateWithSubstring(nil, textCF, range).__conversion() as String
            
            if lastRangeMax < range.location {
                var r = CFRangeMake(lastRangeMax, range.location - lastRangeMax)
                var s = CFStringCreateWithSubstring(nil, textCF, r).__conversion() as String
                
                tokens.append(TextToken(s, hasDefinition: false))
            }
            
            lastRangeMax = range.location + range.length
            
            if countElements(subString) > 1 || subString.isPrimarilyKanji()
            {
                if let card = managedObjectContext.fetchCardByKanji(subString)
                {
                    tokens.append(TextToken(
                        subString,
                        hasDefinition: true,
                        index: card.index))
                    
                    subString = ""
                }
            }
            
            if subString != "" {
                tokens.append(TextToken(subString, hasDefinition: false))
            }
        }
        
        formatDisplay()
    }
    
    func onTouch(gesture: UIGestureRecognizer) {
        
        let location = gesture.locationInView(userText)
        let layout = userText.layoutManager
        
        var index = layout.characterIndexForPoint(location, inTextContainer: userText.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if index < userText.textStorage.length {
            var range: NSRange = NSMakeRange(0, 1)
            if let value = userText.attributedText.attribute("hasDefinition", atIndex: index, effectiveRange: &range) as? NSNumber {
                
                if value != -1 {
            
                    var kanji = managedObjectContext.fetchCardByIndex(value)?.kanji
                    
                    if let kanji = kanji {
                        
                        Globals.notificationShowDefinition.postNotification(kanji)
                    }
                }
            }
        }
    }
}