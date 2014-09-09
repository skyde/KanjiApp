import Foundation
import UIKit

struct Globals
{
    static let notificationSidebarInteract = Notification<Bool>("notificationSidebarInteract", false)
    static let notificationShowDefinition = Notification<String>("showDefinitionNotification", "")
    static let notificationTransitionToView = Notification<View>("transitionToViewNotification", .Search)
    static let notificationAddWordsFromList = Notification<WordList>("addWordsFromListNotification", .MyWords)
    static let notificationEditCardProperties = Notification<CardPropertiesType>("editCardPropertiesNotification", .Pending)
    static let notificationGameViewDidAppear = Notification<CustomUIViewController!>("gameViewDidAppear", nil)
    // If this is true then words are added from the list without the prompt to choose a different list
//    static var viewCards: [NSNumber] = []
//    static var listsTitle = ""
//    static var autoAddWordsFromList = false
    
    static let DefaultFont = "Hiragino Kaku Gothic ProN W3"
    static let JapaneseFont = "M+ 2p"//mplus-2p-regular
    
    static let JapaneseFontLight = "mplus-2p-light"
    
    static let textStudying = "Studying"
    static let textPending = "Pending"
    static let textSuspended = "Suspended"
    
    static let textStudy = "Study"
    static let textPend = "Pend"
    static let textSuspend = "Suspend"
    
    static var colorFunctions: UIColor! = UIColor(white: 170.0 / 255.0, alpha: 1)
    static var colorMyWords: UIColor! = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
    static var colorKnown: UIColor! = UIColor(
        red: 102.0 / 255.0,
        green: 204.0 / 255.0,
        blue: 255.0 / 255.0,
        alpha: 1)
    static var colorLists: UIColor! = UIColor(
        red: 255.0 / 255.0,
        green: 102.0 / 255.0,
        blue: 102.0 / 255.0,
        alpha: 1)
    static var colorOther: UIColor! = UIColor(white: 170.0 / 255.0, alpha: 1)
    
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
    
    private static var _audioDirectoryPath: NSString?
    
    private static func initAudioDirectoryPath() {
        if _audioDirectoryPath == nil {
        let filemgr = NSFileManager.defaultManager()
        
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        
        var documentsDirectory = paths.objectAtIndex(0) as NSString
        var audioPath = documentsDirectory.stringByAppendingPathComponent("Audio")
        _audioDirectoryPath = audioPath
        }
    }
    
    static var audioDirectoryPath: NSString {
    get {
        initAudioDirectoryPath()
            
        return _audioDirectoryPath!
    }
    }
    
    static var audioDirectoryExists: Bool {
        get {
            initAudioDirectoryPath()
            
            let filemgr = NSFileManager.defaultManager()
//            var boolPointer: UnsafeMutablePointer<ObjCBool> = nil
//            var trueBool = true
//            boolPointer = &trueBool
            
//            println(filemgr.fileExistsAtPath(audioDirectoryPath))
            
            return filemgr.fileExistsAtPath(audioDirectoryPath)
//        filemgr.
//        var dirFiles = filemgr.contentsOfDirectoryAtPath(audioPath, error: nil) as NSArray
//
//        for file in dirFiles {
//
//            println(file)
//        }
//        return true
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
//extension String {
//    subscript (r: Range<Int>) -> String {
//        get {
//            let startIndex = advance(self.startIndex, r.startIndex)
//            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
//            
//            return self[Range(start: startIndex, end: endIndex)]
//        }
//    }
//}