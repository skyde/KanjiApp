//
//  ViewController.swift
//  KanjiApp
//
//  Created by Sky on 2014-06-10.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var outputText: UILabel
    
    let deck: Card[]
    var due: Card[]
    
    var isFront: Bool = true;
    
    init(coder aDecoder: NSCoder!) {
        self.deck = []
        
//        self.due = [Card("挨拶", "あいさつ", "a greeting", "She greeted him with a smile.", "彼女は笑顔で挨拶した。", 1),
//            Card("報告", "ほうこく", "report", "There's a report about yesterday's meeting.", "昨日の会議について報告があります。", 0),
//            Card("繊細", "せんさい", "delicate; fine", "She is a very delicate person.", "彼女はとても繊細な人です", 0)]
        
        self.due = []
        
        super.init(coder: aDecoder)
        
        self.due = LoadAllCards("AllCards");
    }
    
    func LoadAllCards(filename: String) -> Card[]
    {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        
        var value: Card[] = []
        
        if let content = possibleContent {
            var deck = content.componentsSeparatedByString("\n")
            
            for deckItem in deck
            {
                var items = deckItem.componentsSeparatedByString("\t")
                
                var index: Int = items[1].toInt()!
                var pitchAccent = 0
                if var p = items[12].toInt()
                {
                    pitchAccent = p
                }
                
                var add: Card = Card(
                    kanji: items[0],
                    index: index,
                    hiragana: items[2],
                    definition: items[3],
                    exampleEnglish: items[4],
                    exampleJapanese: items[5],
                    soundWord: items[6],
                    soundDefinition: items[7],
                    definitionOther: items[8],
                    usageAmount: items[9].toInt()!,
                    usageAmountOther: 0,
                    pitchAccentText: items[11],
                    pitchAccent: pitchAccent,
                    otherExampleSentences: items[13])
                
                value += add
//                let kanji = ""
//                let index = 0
//                let hiragana = ""
//                let definition = ""
//                let exampleEnglish = ""
//                let exampleJapanese = ""
//                let soundWord = ""
//                let soundDefinition = ""
//                let definitionOther = ""
//                let usageAmount = 0
//                let usageAmountOther = 0
//                let pitchAccentText = 0
//                let pitchAccent = 0
//                let otherExampleSentences = 0

//                var i: Int = 0
//                for item in )
//                {
//                    println(item)
//                    println("\n")
//                    
//                    switch i
//                    {
//                        case 0:
//                        
//                        
//                    }
//                    
//                    i++
//                }
            }
        }
        
        return value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTap () {
        if(!isFront && due.count > 1)
        {
            due.removeAtIndex(0)
        }
        
        isFront = !isFront
        
        updateText()
    }
    
    func updateText()
    {
        if(isFront) {
            outputText.attributedText = due[0].front
        }
        else {
            outputText.attributedText = due[0].back
        }
    }
}