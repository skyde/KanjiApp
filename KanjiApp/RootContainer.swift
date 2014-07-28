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

class RootContainer: CustomUIViewController {
    
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var definitionOverlay: UIView!
    
    var sidebarButtonBaseFrame: CGRect!
    var statusBarHidden = false
    let popoverAnimationSpeed = 0.4
    let sidebarEasing = UIViewAnimationOptions.CurveEaseIn
    
    override func isGameView() -> Bool {
        return false
    }
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        
        animateSelf(mainView.frame.origin.x == 0)
    }
    
    private func animateSelf(open: Bool) {
        
//        let animationSpeed = 0.4
        let xMove: CGFloat = 272
        
        if open {
            sidebar.hidden = false
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.mainView.frame = CGRectMake(xMove, self.mainView.frame.origin.y, self.mainView.frame.width, self.mainView.frame.height);
            }
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.sidebarButton.frame = CGRectMake(
                    self.sidebarButtonBaseFrame.origin.x + xMove,
                    self.sidebarButtonBaseFrame.origin.y,
                    self.sidebarButton.frame.width,
                    self.sidebarButton.frame.height);
            }
        }
        else
        {
            UIView.animateWithDuration(popoverAnimationSpeed,
            delay: NSTimeInterval(),
            options: sidebarEasing,
            animations: {
                self.mainView.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height); },
                completion: { (_) -> Void in if self.mainView.layer.presentationLayer().frame.origin.x == 0 { self.sidebar.hidden = true } })
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
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
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
//    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        definitionOverlay.hidden = true
        sidebar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
//        mainView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        self.view.sendSubviewToBack(mainView)
        self.view.sendSubviewToBack(sidebar)
        
        sidebarButtonBaseFrame = sidebarButton.frame
        
        addToNotifications()
        
//        UIView.animateWithDuration(popoverAnimationSpeed) {
//            self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height);
//        }
    }
    
    func onNotificationShowDefinition() {
        
        var animationSpeed = 0.4
        
        println("onNotificationShowDefinition \(Globals.currentDefinition)")
        
        if Globals.currentDefinition == "" {
//            definitionOverlay.hidden = true
            
//            UIView.animateWithDuration(popoverAnimationSpeed) {
//                self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height);
//                }
            
            
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: sidebarEasing,
                animations: {
                    self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height); },
                completion: { (_) -> Void in if self.definitionOverlay.layer.presentationLayer().frame.origin.x == self.mainView.frame.width { self.definitionOverlay.hidden = true }})
            
            
            
            
        } else {
            definitionOverlay.hidden = false
            
            self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height)
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.definitionOverlay.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height);
            }
        }
        
        
        
        
        
//        if Globals.currentDefinition == "" {
//            //            UIView.animateWithDuration(popoverAnimationSpeed) {
//            //
//            //            }
//            UIView.animateWithDuration(popoverAnimationSpeed,
//                delay: NSTimeInterval(),
//                options: sidebarEasing,
//                animations: {
//                    self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height); },
//                completion: { (_) -> Void in if self.mainView.layer.presentationLayer().frame.origin.x == self.mainView.frame.width { self.sidebar.hidden = false } })
//        } else {
//            definitionOverlay.hidden = false
//            
//            UIView.animateWithDuration(popoverAnimationSpeed) {
//                self.definitionOverlay.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height);
//            }
//        }
        
        
        
        
        
    }
    
    override func addToNotifications() {
        super.addToNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotificationShowDefinition", name: Globals.notificationShowDefinition, object: nil)
    }
    
//    func removeFromNotifications() {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
}