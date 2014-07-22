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

class TextReader: CustomUIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var userText : UITextView!
    var items: [NSNumber] = []
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func addAll(sender: AnyObject) {
        for index in items {
            var card = managedObjectContext.fetchCardByIndex(index)
            card.enabled = true
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
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        items = []
        
        userText.font = UIFont(name: Globals.JapaneseFont, size: 20)
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row])
        
        cell.textLabel.attributedText = card.cellText//"\(card.kanji) \(card.interval)"
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
}