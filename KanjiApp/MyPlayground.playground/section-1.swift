// Playground - noun: a place where people can play

import UIKit

class Card {
    init(_ kanji: String, _ definition: String, _ exampleEnglish: String, _ exampleJapanese: String, _ pitchAccent: Int) {
        self.kanji = kanji;
        self.definition = definition;
        self.exampleEnglish = exampleEnglish;
        self.exampleJapanese = exampleJapanese;
        self.pitchAccent = pitchAccent;
        
        interval = 0.0
    }
    
    let kanji = ""
    let definition = ""
    let exampleEnglish = ""
    let exampleJapanese = ""
    let pitchAccent = 0
    
    var interval = 0.0
    
    var front: String {
    get {
        return kanji
    }
    }
    
    var back: String {
    get {
        return definition
    }
    }
}


var due = [Card("挨拶", "a greeting", "She greeted him with a smile", "彼女は笑顔で挨拶した。", 1),
    Card("報告", "report", "There's a report about yesterday's meeting.", "昨日の会議について報告があります。", 0),
    Card("繊細", "delicate; fine", "She is a very delicate person.", "彼女はとても繊細な人です", 0)]

var t = due[1].kanji
due