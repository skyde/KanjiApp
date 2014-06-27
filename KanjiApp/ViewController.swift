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
        
        self.due = [Card("挨拶", "あいさつ", "a greeting", "She greeted him with a smile.", "彼女は笑顔で挨拶した。", 1),
            Card("報告", "ほうこく", "report", "There's a report about yesterday's meeting.", "昨日の会議について報告があります。", 0),
            Card("繊細", "せんさい", "delicate; fine", "She is a very delicate person.", "彼女はとても繊細な人です", 0)]
        
        super.init(coder: aDecoder)
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