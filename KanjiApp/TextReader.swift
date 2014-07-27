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

class TextReader: CustomUIViewController {
    @IBOutlet var userText : UITextView!
    var items: [NSNumber] = []
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func addAll(sender: AnyObject) {
        for index in items {
            if var card = managedObjectContext.fetchCardByIndex(index) {
             card.enabled = true
            }
        }
        saveContext()
    }
    
    @IBAction func onTranslate(sender: AnyObject) {
        tokenizeText()
    }
    
    func tokenizeText() {
        let textNS:NSString = userText.text as NSString
        let textCF:CFString = textNS as CFString
        let length = textNS.length
        
        let tokenizer = CFStringTokenizerCreate(nil, textCF, CFRangeMake(0, length), 0, CFLocaleCreate(nil, "ja_JP"))
        
        while CFStringTokenizerAdvanceToNextToken(tokenizer) != .None {
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let subString = CFStringCreateWithSubstring(nil, textCF, range)
            
            if countElements(subString.__conversion() as String) > 1 || (subString.__conversion() as String).isPrimarilyKanji()
            {
                if let card = managedObjectContext.fetchCardByKanji(subString.__conversion())
                {
                    items += card.index
                }
            }
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = []
        
        userText.font = UIFont(name: Globals.JapaneseFontLight, size: 24)
//        userText.textContainerInset.top = 44
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userText.scrollRangeToVisible(NSRange(location: 0, length: 1))
        //        userText.scrollEnabled = false
//        userText.scrollEnabled = true
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        println(userText.contentOffset)
//        
//    }
//    override
//
//
////        var text = userText.text
////        
////        userText.text = ""
////        
////        userText.scrollEnabled = false
//////        userText.text = text
////        userText.scrollEnabled = true
////        let animationSpeed = 0.4
////        //        UIView.animateWithDuration(animationSpeed) {}
////        UIView.animateWithDuration(animationSpeed) {
////            self.userText.contentOffset = CGPoint(x: 0, y: 0)
////        }
//
//    }
    
//    override func viewDidAppear(animated: Bool) {
//        
//    }
//    
//    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        return self.items.count;
//    }
//    
//    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
//        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
//        
//        var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row])
//        
//        cell.textLabel.attributedText = card.cellText//"\(card.kanji) \(card.interval)"
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        println("You selected cell #\(indexPath.row)!")
//    }
}