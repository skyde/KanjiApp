import Foundation

var targetView = View.Search
let transitionToViewNotification = "transitionToViewNotification"

let addWordsFromListNotification = "addWordsFromListNotification"
var addWordsFromList: WordList = WordList.MyWords

struct Globals
{
    static let JapaneseFont = "M+ 2p"//mplus-2p-regular
    
    static let JapaneseFontLight = "mplus-2p-light"
}

func randomRange(min: Double, max: Double) -> Double {
    
    return min + (Double(arc4random())) / 0x100000000 * max
}

func randomRange(min: Int, max: Int) -> Int {
    
    var base:Double = Double(arc4random()) / 0x100000000
    
    return Int(Double(min) + (base * Double(max)))
}