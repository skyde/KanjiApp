import Foundation
import UIKit

struct Globals
{
    static let notificationSidebarInteract = Notification<Bool>("notificationSidebarInteract", false)
    static let notificationShowDefinition = Notification<String>("showDefinitionNotification", "")
    static let notificationTransitionToView = Notification<View>("transitionToViewNotification", .Search)
    static let notificationAddWordsFromList = Notification<WordList>("addWordsFromListNotification", .MyWords)
    // If this is true then words are added from the list without the prompt to choose a different list
//    static var viewCards: [NSNumber] = []
//    static var listsTitle = ""
//    static var autoAddWordsFromList = false
    
    static let DefaultFont = "Hiragino Kaku Gothic ProN W3"
    static let JapaneseFont = "M+ 2p"//mplus-2p-regular
    
    static let JapaneseFontLight = "mplus-2p-light"
    
    static var screenRect: CGRect {
        get {
            var size = UIScreen.mainScreen().bounds.size
            return CGRectMake(0, 0, size.width, size.height)
    }
    }
    
    static var screenSize: CGSize {
        get {
            return UIScreen.mainScreen().bounds.size
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