//
//  Search.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-24.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

class Search : CustomUIViewController {
    
    var discoverLabels: [DiscoverAnimatedLabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        discoverLabels.map { self.animateLabel($0) }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        discoverLabels = []
        
        for item in self.view.subviews {
            if let label = item as? DiscoverAnimatedLabel {
                discoverLabels += label
                self.animateLabel(label)
            }
        }
    }
    
    func animateLabel(label: DiscoverAnimatedLabel) {
        
        println(label)
        
        var animationLength = 8.0
    
//        label.constraints().removeAll(keepCapacity: false)
        
        label.frame = CGRectMake(label.frame.origin.x, 500, label.frame.width, label.frame.height);
        
                UIView.animateWithDuration(animationLength) {
                    label.frame = CGRectMake(0, 500, label.frame.width, label.frame.height)
                }
    }
}