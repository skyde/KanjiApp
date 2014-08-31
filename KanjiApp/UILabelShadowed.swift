//
//  UILabelShadowed.swift
//  Kanji
//
//  Created by Sky on 2014-08-31.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public class UILabelShadowed : UILabel {
    public required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        initSelf()
    }
    
    private func initSelf() {
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 0)
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shouldRasterize = true
    }
}