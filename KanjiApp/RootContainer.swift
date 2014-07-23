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
    
    var sidebarButtonBaseFrame: CGRect!
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        println("down")
        
//        mainView.frame = CGRect(x: 300, y: 0, width: mainView.frame.width, height: mainView.frame.height)
        
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
        
//        sidebarButton.layer.transform = CATransform3DMakeScale(0.6,0.6,1)
//        UIView.animateWithDuration(0.25, animations: {
//            self.sidebarButton.layer.transform = CATransform3DMakeScale(1,1,1)
//            })
        
//        mainView.layer.transform = CATransform3DMakeTranslation(-100, 0, 0)
//        mainView.hidden = true
//        UIView.animateWithDuration(0.25, animations: {
//            self.sidebarButton.layer.transform = CATransform3DMakeScale(1,1,1)
//            })
        
//        mainView.frame = CGRectMake(100, 200, mainView.frame.size.width, mainView.frame.size.height)
    }
    
//    func animateYToPostion(theView: UIView, newYPos: Float){
//        UIView.animateWithDuration(0.3, animations: ({ () -> Void in
//            theView.frame = CGRectMake(theView.frame.origin.x, newYPos, theView.frame.size.width, theView.frame.size.height);
//            }));
    
    init(coder aDecoder: NSCoder!) {
        
        super.init(coder: aDecoder)
        
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