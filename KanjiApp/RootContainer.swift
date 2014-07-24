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

var targetView = View.Search

class RootContainer: CustomUIViewController {
    
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    
    var sidebarButtonBaseFrame: CGRect!
    var statusBarHidden = false
    
    
    override func isGameView() -> Bool {
        return false
    }
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        
        animateSelf(mainView.frame.origin.x == 0)
    }
    
    private func animateSelf(open: Bool) {
        
        let animationSpeed = 0.4
        let xMove: CGFloat = 272
        
        if open {
            UIView.animateWithDuration(animationSpeed) {
                self.mainView.frame = CGRectMake(xMove, self.mainView.frame.origin.y, self.mainView.frame.width, self.mainView.frame.height);
            }
            
            UIView.animateWithDuration(animationSpeed) {
                self.sidebarButton.frame = CGRectMake(
                    self.sidebarButtonBaseFrame.origin.x + xMove,
                    self.sidebarButtonBaseFrame.origin.y,
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
    }

    override func onTransitionToView() {
        super.onTransitionToView()
        
        animateSelf(false)
        
        //switch ta
        
//        statusBarHidden = true
        
//        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        
        sidebarButtonBaseFrame = sidebarButton.frame
    }
}