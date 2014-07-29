import Foundation
import UIKit

class DiscoverAnimatedLabel: UILabel {
    var kanji: String = ""
    var column: Int = 0
    
    var animatedPosition: CGPoint? {
    get {
        return layer?.presentationLayer()?.frame?.origin
    }
    }
}