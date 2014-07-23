//
//  RootContainer.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-22.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

var targetView = ""

class RootContainer: CustomUIViewController {
    
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    
    var sidebarButtonBaseFrame: CGRect!
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        
        let animationSpeed = 0.5
        let xMove: CGFloat = 272
        
        if mainView.frame.origin.x == 0
        {
            UIView.animateWithDuration(animationSpeed) {
                self.mainView.frame = CGRectMake(xMove, 0, self.mainView.frame.width, self.mainView.frame.height);
            }
            
            UIView.animateWithDuration(animationSpeed) {
                self.sidebarButton.frame = CGRectMake(
                    self.sidebarButtonBaseFrame.origin.x + xMove,
                    0,
                    self.sidebarButton.frame.width,
                    self.sidebarButton.frame.height);
            }
        }
        else
        {
            UIView.animateWithDuration(animationSpeed) {
                self.mainView.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height);
            }
            
            UIView.animateWithDuration(animationSpeed) {
                self.sidebarButton.frame = self.sidebarButtonBaseFrame;
            }
        }
        
        
    }
    
    init(coder aDecoder: NSCoder!) {
        
        super.init(coder: aDecoder)
        
//        mainView.addSubview(view: UIView?)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        
        sidebarButtonBaseFrame = sidebarButton.frame
        
    }
}