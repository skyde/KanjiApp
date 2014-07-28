import Foundation
import UIKit

struct Globals
{
    static let notificationShowDefinition = "showDefinitionNotification"
    static var currentDefinition: String = ""
    
    static let notificationTransitionToView = "transitionToViewNotification"
    
    static let notificationAddWordsFromList = "addWordsFromListNotification"
    static var addWordsFromList: WordList = WordList.MyWords
    static var targetView = View.Search
    
    static let JapaneseFont = "M+ 2p"//mplus-2p-regular
    
    static let JapaneseFontLight = "mplus-2p-light"
    
    static var screenRect: CGRect {
    get {
        var size = UIScreen.mainScreen().bounds.size
        return CGRectMake(0, 0, size.width, size.height)
    }
    }
}

func randomRange(min: Double, max: Double) -> Double {
    
    return min + (Double(arc4random())) / 0x100000000 * max
}

func randomRange(min: Int, max: Int) -> Int {
    
    var base:Double = Double(arc4random()) / 0x100000000
    
    return Int(Double(min) + (base * Double(max)))
}