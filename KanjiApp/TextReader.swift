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
    @IBOutlet var userText : UITextView
    var items: [NSNumber] = []
    
    @IBOutlet var tableView: UITableView
    @IBAction func addAll(sender: AnyObject) {
    }
    @IBAction func onTranslate(sender: AnyObject) {
        tokenizeText()
    }
    
    func tokenizeText() {
        let textNS:NSString = userText.text as NSString
        let textCF:CFString = textNS as CFString
        let length = textNS.length
        
        let tokenizer = CFStringTokenizerCreate(nil, textCF, CFRangeMake(0, length), 0, CFLocaleCreate(nil, "ja_JP"))
        
        while(CFStringTokenizerAdvanceToNextToken(tokenizer) != .None) {
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let subString = CFStringCreateWithSubstring(nil, textCF, range)
            
            println(subString)
            
//            tokens.append(Token(text:subString, range:range.ToNSRange()))
        }
        
        let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("didload")
        
        items = [1, 1, 1, 1, 2]
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        println(items.count)
        return self.items.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        //var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row])
        
        cell.textLabel.text = "\(self.items[indexPath.row])"//"\(card.kanji) \(card.interval)"
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }
}