import Foundation
import UIKit

struct Globals
{
    static let notificationSidebarInteract = Notification<Bool>("notificationSidebarInteract", false)
    static let notificationShowDefinition = Notification<String>("showDefinitionNotification", "")
    static let notificationTransitionToView = Notification<View>("transitionToViewNotification", .Search)
    static let notificationAddWordsFromList = Notification<WordList>("addWordsFromListNotification", .MyWords)
    static let notificationEditCardProperties = Notification<CardPropertiesEdit>("editCardPropertiesNotification", .Add)
    static let notificationGameViewDidAppear = Notification<CustomUIViewController!>("gameViewDidAppear", nil)
    // If this is true then words are added from the list without the prompt to choose a different list
//    static var viewCards: [NSNumber] = []
//    static var listsTitle = ""
//    static var autoAddWordsFromList = false
    
    static let DefaultFont = "Hiragino Kaku Gothic ProN W3"
    static let JapaneseFont = "M+ 2p"//mplus-2p-regular
    
    static let JapaneseFontLight = "mplus-2p-light"
    
    static var colorFunctions: UIColor! = nil
    static var colorMyWords: UIColor! = nil
    static var colorKnown: UIColor! = nil
    static var colorLists: UIColor! = nil
    static var colorOther: UIColor! = nil
    
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
    
    static var secondsSince1970: Double {
        get {
            return NSDate().timeIntervalSince1970
        }
    }
    
    private static var cachedRetinaScale: CGFloat! = nil
    static var retinaScale: CGFloat {
        get {
            if cachedRetinaScale == nil {
                cachedRetinaScale = UIScreen.mainScreen().scale
            }
            
            return cachedRetinaScale
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

func distanceGreater(a: CGPoint, b: CGPoint, greaterThan: CGFloat) -> Bool {
    return (a.x - b.x) * (a.y - b.y) > greaterThan * greaterThan
}

func distanceLess(a: CGPoint, b: CGPoint, greaterThan: CGFloat) -> Bool {
    return (a.x - b.x) * (a.y - b.y) <= greaterThan * greaterThan
}

func distanceAmount(a: CGPoint, b: CGPoint) -> CGFloat {
    return sqrt(abs((a.x - b.x) * (a.y - b.y)))
}

func sign(value: CGFloat) -> CGFloat {
    if value > 0 {
        return 1
    } else if value < 0 {
        return -1
    }
    
    return 1
}

extension UIView {
    var visible: Bool {
        get {
            return !hidden
        }
        set {
            hidden = !newValue
        }
    }
}