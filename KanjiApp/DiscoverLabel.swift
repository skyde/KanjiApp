import Foundation
import UIKit

class DiscoverLabel: UILabel {
//    var index = 0
    var kanji = ""
    var column = 0
    
//    var animatedPosition: CGPoint? {
//    get {
//        return layer?.presentationLayer()?.frame?.origin
//    }
//    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        
        self.numberOfLines = 0
    }
}