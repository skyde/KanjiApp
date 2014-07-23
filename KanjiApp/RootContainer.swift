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
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        println("down")
        
        sidebarButton.layer.transform = CATransform3DMakeScale(0.6,0.6,1)
        UIView.animateWithDuration(0.25, animations: {
            self.sidebarButton.layer.transform = CATransform3DMakeScale(1,1,1)
            })
        
//        mainView.frame = CGRect(x: 300, y: 0, width: mainView.frame.width, height: mainView.frame.height)
        
        if mainView.frame.origin.x == 0
        {
            UIView.animateWithDuration(0.5, animations: ({ () -> Void in
                self.mainView.frame = CGRectMake(300, 0, self.mainView.frame.width, self.mainView.frame.height);
                }))
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: ({ () -> Void in
                self.mainView.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height);
                }))
        }
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
    }
}