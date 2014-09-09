import Foundation
import UIKit

class DiscoverLabel: UILabel, UIGestureRecognizerDelegate {
    var kanji = ""
    var column: Int = 0
    var depth: Double = 0
    
    var onTouch: ((label: DiscoverLabel) -> ())? = nil
    
    private func initSelf() {
        
        layer.rasterizationScale = Globals.retinaScale
        
//        backgroundColor = UIColor.clearColor()
        numberOfLines = 0
    }
    
    func setupLabelFromData(data: DiscoverLabelData, width: CGFloat) {
        kanji = data.kanji
        frame = CGRectMake(0, 0, width, data.height)
        
        depth = data.distance
        
//        setTitle("test", forState: .Normal)

        attributedText = data.attributedText
        
        textColor = UIColor(
            red: CGFloat(data.distance * 0.4),
            green: CGFloat(data.distance * 0.85),
            blue: CGFloat(data.distance * 1),
            alpha: 1)
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSelf()
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        initSelf()
    }
    
}