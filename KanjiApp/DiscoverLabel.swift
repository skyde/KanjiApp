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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSelf()
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        initSelf()
    }
    
    private func initSelf() {
        
//        layer.shadowColor = UIColor.blackColor().CGColor
//        layer.shadowOffset = CGSizeMake(0, 0)
//        layer.masksToBounds = false
//        layer.shadowRadius = 4
//        layer.shadowOpacity = 0.07
//        layer.shouldRasterize = true
    }
    //override
}