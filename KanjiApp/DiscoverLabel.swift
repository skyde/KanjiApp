import Foundation
import UIKit

class DiscoverLabel: UILabel {
//    var index = 0
    var kanji = ""
    var column = 0
    
//    var onTouch: ((label: DiscoverLabel) -> ())? = nil
    
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
        
        layer.rasterizationScale = Globals.retinaScale
        
//        layer.shadowColor = UIColor.blackColor().CGColor
//        layer.shadowOffset = CGSizeMake(0, 0)
//        layer.masksToBounds = false
//        layer.shadowRadius = 7
//        layer.shadowOpacity = 0.2
//        layer.shouldRasterize = true
        
    }
    
    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
//        return true
//    }
    //override
}